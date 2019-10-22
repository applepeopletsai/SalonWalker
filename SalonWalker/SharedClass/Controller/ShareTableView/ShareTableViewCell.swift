//
//  ShowTableViewCell.swift
//  SalonWalker
//
//  Created by Scott.Tsai on 2018/5/19.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ShareTableViewCell: UITableViewCell {

    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCellWith(itemString: String , isSelect: Bool) {
        self.itemLabel.text = itemString
        if isSelect {
            self.tickImage.image = UIImage(named: "checkbox_checked_20x20")
        } else {
            self.tickImage.image = UIImage(named: "checkbox_normal_20x20")
        }
    }
}
