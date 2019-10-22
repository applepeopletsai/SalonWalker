//
//  PaySchemeTableViewCell.swift
//  SalonWalker
//
//  Created by Scott.Tsai on 2018/4/28.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class PaySchemeTableViewCell: UITableViewCell {

    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var unitLabel: UILabel!
    @IBOutlet private weak var tickImageView: UIImageView!
    @IBOutlet private weak var tickBottomView: UIView!
    @IBOutlet private weak var tickBottomViewWidth: NSLayoutConstraint!

    func setupCellWith(model: Codable, showSchemeType: ShowPaySchemeType, chooseSchemeType: PaySchemeType, select: Bool) {
        switch chooseSchemeType {
        case .hour:
            self.unitLabel.text = LocalizedString("Lang_PS_009")
            break
        case .times:
            self.unitLabel.text = LocalizedString("Lang_PS_010")
            break
        case .longRent:
            self.unitLabel.isHidden = true
            break
        }
        
        if (showSchemeType == .check) {
            tickBottomView.isHidden = true
            tickBottomViewWidth.constant = 0
        } else {
            tickBottomView.isHidden = false
            tickBottomViewWidth.constant = 50
        }
        
        self.timeLabel.textColor = .black
        self.priceLabel.textColor = .black
        if let model = model as? HoursAndTimesPricesModel {
            self.timeLabel.text = model.weekDay.transferToWeekString()
            self.priceLabel.text = "$\(String(model.prices))"
        } else if let model = model as? LongLeasePricesModel {
            if let startDay = model.startDay, let endDay = model.endDay, let price = model.prices {
                self.timeLabel.text = startDay.replacingOccurrences(of: "-", with: "/") + " \(LocalizedString("Lang_DD_012")) " + endDay.replacingOccurrences(of: "-", with: "/")
                self.priceLabel.text = String(price)
                // 過期的顯示灰色字體，而且不可選
                if endDay.transferToDate(dateFormat: "yyyy-MM-dd") < Date() {
                    self.timeLabel.textColor = color_9B9B9B
                    self.priceLabel.textColor = color_9B9B9B
                    self.tickBottomView.isHidden = true
                }
            }
        } else {
            self.timeLabel.isHidden = true
            self.priceLabel.isHidden = true
        }
        
        self.tickImageView.image = (select) ? UIImage(named: "checkbox_checked_20x20") : UIImage(named: "checkbox_normal_20x20")
    }
}
