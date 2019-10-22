//
//  AverageCostTableViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class AverageCostTableViewCell: UITableViewCell {

    @IBOutlet weak var singleTimeLabel: UILabel!
    @IBOutlet weak var singleMonthLabel: UILabel!
    @IBOutlet weak var singleYearLabel: UILabel!
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set(newFrame) {
            var frame = newFrame
            frame.origin.x += 25
            frame.origin.y += 10
            frame.size.width -= 50
            frame.size.height -= 20
            super.frame = frame
            self.makeShadowAndCornerRadius()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCellWith(model: CustomerPayHistoryModel.AvgPrices) {
        self.singleTimeLabel.text = "$\(model.one.transferToDecimalString())"
        self.singleMonthLabel.text = "$\(model.month.transferToDecimalString())"
        self.singleYearLabel.text = "$\(model.year.transferToDecimalString())"
    }

}
