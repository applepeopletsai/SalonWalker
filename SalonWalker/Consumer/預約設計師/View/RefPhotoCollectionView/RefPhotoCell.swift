//
//  RefPhotoCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/10.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class RefPhotoCell: UICollectionViewCell {
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var selectImageView: UIImageView!
    
    func setupCellWithModel(_ model: RefPhotoModel.RefPhoto) {
        self.photoImageView.setImage(with: model.photoImgUrl)
        self.selectImageView.isHidden = !model.select!
    }
}
