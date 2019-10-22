//
//  StoreEquipmentSuppliesCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/20.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class StoreEquipmentSuppliesCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCellWithModel(_ model: EquipmentModel) {
        self.titleLabel.text = model.name
        self.contentLabel.text = model.characterization
    }
}
