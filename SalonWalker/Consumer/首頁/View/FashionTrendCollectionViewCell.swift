//
//  FashionTrendCollectionViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/3/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class FashionTrendCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWith(model: ArticleModel) {
        self.titleLabel.text = model.title
        if let url = model.imgUrl {
            self.collectionImage.setImage(with: url)
        } else {
            self.collectionImage.image = nil
        }
        if let color = model.titleColor {
            self.titleLabel.textColor = ColorTool.colorWith(hexString: color, alpha: 1.0)
        }
    }

}

