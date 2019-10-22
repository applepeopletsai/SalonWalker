//
//  FashionTrendCollectionCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/12/20.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum FashionTrendType {
    case general, tips, tools
}

class FashionTrendCollectionCell: UICollectionViewCell {
    
    @IBInspectable var circleable: Bool = false
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var imageViewLeftConstraint: NSLayoutConstraint?
    @IBOutlet private weak var imageViewRightConstraint: NSLayoutConstraint?
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if circleable {
            makeImageViewCircle()
        }
    }
    
    func setupCellWith(model: ArticleModel?, fashionTrendType: FashionTrendType) {
        self.isHidden = true
        if let model = model {
            if let url = model.imgUrl {
                self.imageView.setImage(with: url)
            } else {
                self.imageView.image = nil
            }
            if let color = model.titleColor {
                self.titleLabel.textColor = ColorTool.colorWith(hexString: color, alpha: 1.0)
            } else {
                self.titleLabel.textColor = .black
            }
            switch fashionTrendType {
            case .general:
                self.titleLabel.text = model.title
                break
            case .tips:
                self.titleLabel.text = "TIPS"
                break
            case .tools:
                self.titleLabel.text = "TOOLS"
                break
            }
            
            self.isHidden = false
        }
    }
    
    private func makeImageViewCircle() {
        if self.imageView.bounds.size.height > self.bounds.size.height * 0.8 {
            self.imageViewLeftConstraint?.constant += 10
            self.imageViewRightConstraint?.constant += 10
            self.layoutIfNeeded()
            self.makeImageViewCircle()
        } else {
            self.imageView.layer.cornerRadius = self.imageView.bounds.size.width / 2
        }
    }
}
