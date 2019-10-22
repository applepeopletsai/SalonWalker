//
//  EUAImageCell.swift
//  SalonWalker
//
//  Created by Cooper on 2018/8/28.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Photos

class EUAImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupEUAImage(photo: MediaModel) {
        if let imageUrl = photo.photoUrl {
            self.imageView.setImage(with: imageUrl)
        }
        if let localIdentifier = photo.imageLocalIdentifier, localIdentifier.count != 0 {
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
            if let asset = assets.firstObject {
                MultipleAsset(originalAsset: asset).fetchOriginalImage { (image, info) in
                    if let image = image {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
}
