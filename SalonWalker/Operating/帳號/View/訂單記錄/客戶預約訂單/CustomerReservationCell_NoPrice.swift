//
//  CustomerReservationCell_NoPrice.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/23.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class CustomerReservationCell_NoPrice: UITableViewCell {

    @IBOutlet private weak var orderNoLabel: UILabel!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.x += 15
            frame.origin.y += 6
            frame.size.width -= 30
            frame.size.height -= 12
            super.frame = frame
            self.makeShadowAndCornerRadius()
        }
    }

    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.photoImageView.layer.cornerRadius = self.photoImageView.bounds.width / 2
        self.photoImageView.layer.masksToBounds = true
    }
    
    // MARK: Method
    func setupCellWtihModel(_ model: OrderListModel.OrderList) {
        self.orderNoLabel.text = "\(LocalizedString("Lang_RD_005"))：\(model.orderNo)"
        self.nameLabel.text = model.nickName
        self.statusLabel.text = "(\(model.orderStatusName))"
        if (model.cityName?.count ?? 0) > 0 {
            self.cityLabel.text = "\(model.cityName ?? "") \(model.langName ?? "")"
        } else {
            self.cityLabel.text = model.langName
        }
        if let url = model.headerImgUrl, url.count > 0 {
            self.photoImageView.setImage(with: url)
        } else {
            self.photoImageView.image = UIImage(named: "img_account_user")
        }
    }
}


