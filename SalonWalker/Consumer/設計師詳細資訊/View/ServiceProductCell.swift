//
//  ServiceProductCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ServiceProductCell: UITableViewCell {

    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var productNameLabel: UILabel!
    @IBOutlet private weak var bottomLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWith(model: SvcProductModel, hiddenLine: Bool) {
        let attribute_brand = [NSAttributedString.Key.foregroundColor: color_8F92F5]
        let attribute_product = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        if let brand = model.brand, let product = model.product {
            let brandTextRange = NSRange(location: 0, length: brand.count)
            let productTextRange = NSRange(location: brand.count + 1, length: product.count)
            let attr = NSMutableAttributedString(string: "\(brand)\n\(product)")
            attr.addAttributes(attribute_brand, range: brandTextRange)
            attr.addAttributes(attribute_product, range: productTextRange)
            self.productNameLabel.attributedText = attr
        } else {
            self.productNameLabel.attributedText = nil
        }
        if let url = model.imgUrl, url.count > 0 {
            self.productImageView.setImage(with: url)
        } else {
            self.productImageView.image = UIImage(named: "img_account_user")
        }
        self.bottomLine.isHidden = hiddenLine
    }

}
