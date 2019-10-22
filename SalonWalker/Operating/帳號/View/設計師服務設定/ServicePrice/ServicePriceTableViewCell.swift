//
//  ServicePriceTableViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/30.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ServicePriceTableViewCell: UITableViewCell {
  
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWith(categoryModel: SvcCategoryModel) {
        if let iconUrl = categoryModel.iconUrl {
            self.itemImage.setImage(with: iconUrl)
        }
        self.itemLabel.text = categoryModel.name
    }
}
