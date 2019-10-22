//
//  ServicePositionCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ServicePositionCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var storeImageView: UIImageView!
    @IBOutlet private weak var storeNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.text = LocalizedString("Lang_RD_022")
    }
    
    func setupCellWith(model: SvcPlaceModel, indexPath: IndexPath) {
        self.titleLabel.isHidden = !(indexPath.row == 0)
        self.storeNameLabel.text = model.nickName
        if let url = model.headerImgUrl, url.count > 0 {
            self.storeImageView.setImage(with: url)
        } else {
            self.storeImageView.image = UIImage(named: "img_account_user")
        }
    }

}
