//
//  AlbumDetailCell.swift
//  SalonWalker
//
//  Created by Cooper on 2018/8/30.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class AlbumDetailCell: UICollectionViewCell {
    
    @IBOutlet private weak var albumDetailImage: UIImageView!
    @IBOutlet private weak var checkButton: UIButton!
    
    private var status: EditModeStatus = .Normal
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkButton.isHidden = true
        // Initialization code
    }
    
    func setupAlbumDetailCellWith(model: AlbumPhotoModel, status: EditModeStatus) {
        if model.dwapId != -1 {
            albumDetailImage.setImage(with: model.photoUrl)
            
            if status == .Editing{
                checkButton.isHidden = false
                if let selected = model.selected {
                    checkButton.isSelected = selected
                }
            } else {
                checkButton.isHidden = true
            }
        }
    }
}
