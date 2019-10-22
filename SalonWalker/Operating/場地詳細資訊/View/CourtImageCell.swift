//
//  CollectionViewCell.swift
//  TabBar_practice
//
//  Created by Skywind on 2018/3/6.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class CourtImageCell: UICollectionViewCell {
    
    //MARK: IBOutlet
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    
    //MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

