//
//  ConsumeRecordTableViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ConsumeRecordTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWtih(model: CustomerPayHistoryModel.SvcPayHistory) {
        self.dateLabel.text = model.orderTime
        self.priceLabel.text = "NT$\(model.payTotal.transferToDecimalString())"
    }
}
