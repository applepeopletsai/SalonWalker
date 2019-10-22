//
//  SiteReservationCell_NoPrice.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/24.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class SiteReservationCell_NoPrice: UITableViewCell {

    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var customerView: UIView!
    @IBOutlet private weak var orderNoLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var phoneLabel: UILabel!
    @IBOutlet private weak var customerLabel: UILabel!
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.headerImageView.layer.cornerRadius = self.headerImageView.bounds.width / 2
        self.headerImageView.layer.masksToBounds = true
    }
    
    func setupCellWith(model: OrderListModel.OrderList) {
        self.orderNoLabel.text = "\(LocalizedString("Lang_RD_005"))：\(model.orderNo)"
        self.nameLabel.text = model.nickName
        self.addressLabel.text = "\(model.cityName ?? "")\(model.areaName ?? "")\(model.address ?? "")"
        self.statusLabel.text = "(\(model.orderStatusName))"
        
        if let url = model.headerImgUrl, url.count > 0 {
            self.headerImageView.setImage(with: url)
        } else {
            self.headerImageView.image = UIImage(named: "img_account_user")
        }
        if let customerName = model.customerName, customerName.count > 0 {
            self.customerView.isHidden = false
            self.customerLabel.text = customerName
        } else {
            self.customerView.isHidden = true
        }
        if let telArea = model.telArea, let tel = model.tel {
            self.phoneLabel.text = "\(telArea)-\(tel)"
        } else {
            self.phoneLabel.text = nil
        }
    }
}


