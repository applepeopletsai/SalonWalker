//
//  StorePaySchemeTableViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/3.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class StorePaySchemeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchOnLabel: IBInspectableLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWith(title: String, open: Bool) {
        self.titleLabel.text = title
        self.switchOnLabel.isHidden = !open
    }
}
