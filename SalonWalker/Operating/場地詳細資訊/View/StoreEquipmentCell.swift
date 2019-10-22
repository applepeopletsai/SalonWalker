//
//  TableViewCell.swift
//  TabBar_practice
//
//  Created by Skywind on 2018/3/6.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class StoreEquipmentCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWith(model: EquipmentModel, hideTitle: Bool) {
        self.titleLabel.isHidden = hideTitle
        self.nameLabel.text = model.name
        self.countLabel.text = "\(model.num)"
    }
}
