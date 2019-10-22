//
//  StoreAccountCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/14.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class StoreAccountCell: UICollectionViewCell {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var countView: UIView!
    
    func setupCellWith(iconImageString: String, title: String, orderCount: Int, pushCount: Int, indexPath: IndexPath) {
        self.iconImageView.image = UIImage(named: iconImageString)
        self.titleLabel.text = title
        
        if title == LocalizedString("Lang_RD_001") { // 訂單記錄
            if orderCount > 0 {
                self.countLabel.isHidden = false
                self.countView.isHidden = false
                self.countLabel.text = String(orderCount.transferToDecimalString())
            } else {
                self.countLabel.isHidden = true
                self.countView.isHidden = true
            }
        } else if title == LocalizedString("Lang_AC_062") { // 推播通知
            if pushCount > 0 {
                self.countLabel.isHidden = false
                self.countView.isHidden = false
                self.countLabel.text = String(pushCount.transferToDecimalString())
            } else {
                self.countLabel.isHidden = true
                self.countView.isHidden = true
            }
        } else {
            self.countLabel.isHidden = true
            self.countView.isHidden = true
        }
    }
}
