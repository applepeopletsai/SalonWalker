//
//  MyCustomerTableViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class MyCustomerTableViewCell: UITableViewCell {

    @IBOutlet weak private var tickImageView: UIImageView!
    @IBOutlet weak private var tickBaseViewWidth: NSLayoutConstraint!
    @IBOutlet weak private var photoImageView: UIImageView!
    @IBOutlet weak private var nameLabel: UILabel!

    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.photoImageView.layer.cornerRadius = self.photoImageView.bounds.width / 2
    }
    
    // MARK: Method
    func setupCellWith(model: CustomerListModel.CustomerListInfo, type: StatusButtonType) {
        self.nameLabel.text = model.nickName
        self.tickBaseViewWidth.constant = (type == .edit) ? 0 : 50
        self.tickImageView.image = (model.select ?? false) ? UIImage(named: "checkbox_checked_20x20") : UIImage(named: "checkbox_normal_20x20")
        if model.headerImgUrl.count > 0 {
            self.photoImageView.setImage(with: model.headerImgUrl)
        } else {
            self.photoImageView.image = UIImage(named: "img_account_user")
        }
    }
    
    func animateTickButtonImage(type: StatusButtonType) {
        self.tickBaseViewWidth.constant = (type == .edit) ? 0 : 50
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
}
