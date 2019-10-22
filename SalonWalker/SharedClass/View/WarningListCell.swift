//
//  WarningListCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/12/19.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class WarningListCell: UITableViewCell {

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var orderNoLabel: UILabel!
    @IBOutlet private weak var orderNoLabelCenterYConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCellWith(model: WarningDetailModel, type: WarningListType) {
        self.dateLabel.text = model.violationDate
        self.orderNoLabel.text = "\(LocalizedString("Lang_RD_005"))：\(model.orderNo ?? "")"
        
        if type == .caution {
            self.contentLabel.isHidden = false
            self.contentLabel.text = model.eventContent
            self.orderNoLabelCenterYConstraint.constant = -15
        } else {
            self.contentLabel.isHidden = true
            self.orderNoLabelCenterYConstraint.constant = 0
        }
    }
    
}
