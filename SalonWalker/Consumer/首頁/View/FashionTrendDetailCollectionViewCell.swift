//
//  FashionTrendDetailCollectionViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/3/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class FashionTrendDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.makeShadowAndCornerRadius()
        self.setupLabelFont()
    }
    
    func setupCellWith(model: ArticleModel) {
        self.titleLabel.text = model.title
        if let url = model.imgUrl {
            self.imageView.setImage(with: url)
        } else {
            self.imageView.image = nil
        }
        if let time = model.startTime {
            self.dateLabel.text = String(time.prefix(10))
        } else {
            self.dateLabel.text = nil
        }
    }
    
    private func setupLabelFont () {
        if SizeTool.isIphone5(){
            self.titleLabel.font = UIFont.systemFont(ofSize: 12)
            self.dateLabel.font = UIFont.systemFont(ofSize: 10)
        }
        if SizeTool.isIphone6(){
            self.titleLabel.font = UIFont.systemFont(ofSize: 14)
            self.dateLabel.font = UIFont.systemFont(ofSize: 12)
        }
        if SizeTool.isIphone6Plus(){
            self.titleLabel.font = UIFont.systemFont(ofSize: 16)
            self.dateLabel.font = UIFont.systemFont(ofSize: 14)
        }
        if SizeTool.isIphoneX(){
            self.titleLabel.font = UIFont.systemFont(ofSize: 14)
            self.dateLabel.font = UIFont.systemFont(ofSize: 12)
        }
    }
}
