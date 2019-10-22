//
//  DateServiceCollectionCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class DateServiceCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var addImage: UIImageView!
    
    private var index : Int = 0
    
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
