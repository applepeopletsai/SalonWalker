//
//  ServiceItemCell.swift
//  TestImagePicker
//
//  Created by Daniel on 2018/3/8.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ServiceItemCell: UICollectionViewCell {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var addImageView: UIImageView!
    
    func setupWith(image: String, title: String, hidden: Bool) {
        self.imageView.image = UIImage(named: image)
        self.titleLabel.text = title
        self.addImageView.isHidden = hidden
    }
    
    func setupCellWith(model: SvcCategoryModel, hidden: Bool) {
        self.addImageView.isHidden = hidden
        self.titleLabel.text = model.name
        if let url = model.iconUrl {
            self.imageView.setImage(with: url)
        } else {
            self.imageView.image = nil
        }
        
        var price = model.price ?? 0
        if let selectSvcClass = model.selectSvcClass {
            for svcClass in selectSvcClass {
                if let svcItems = svcClass.svcItems {
                    for svcItem in svcItems {
                        price += svcItem.price ?? 0
                    }
                } else {
                    price += svcClass.price ?? 0
                }
            }
        }
        self.priceLabel.text = "$\(price.transferToDecimalString())"
    }
}
