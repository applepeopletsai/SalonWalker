//
//  CommentCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/12.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Cosmos

class CommentCell: UITableViewCell {

    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var starView: CosmosView!
    @IBOutlet private weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWith(_ model: EvaluateDetailModel.List) {
        self.nameLabel.text = model.name
        self.starView.rating = Double(model.point)
        self.contentLabel.text = model.comment
        self.photoImageView.setImage(with: model.headerImgUrl)
    }

}
