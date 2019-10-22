//
//  ServiceContentCollectionCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/18.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ServiceContentCollectionCell: UICollectionViewCell {

    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addImage: UIImageView!
    
    private var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func setupCellWith(index: Int , isHiddenAddImage: Bool) {
        self.index = index
        if isHiddenAddImage {
            addImage.isHidden = true
        } else {
            addImage.isHidden = false
        }
    }
}
