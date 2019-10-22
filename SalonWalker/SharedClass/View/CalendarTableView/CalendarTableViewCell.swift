//
//  CalendarTableViewCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {

    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var photoImageViewWidth: NSLayoutConstraint!
    @IBOutlet private weak var badgeImageView: UIImageView!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var topLineView: UIView!
    @IBOutlet private weak var bottomLineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    private func initialize() {
        if SizeTool.isIphone5() {
            self.photoImageViewWidth.constant = 50.0
        }
        self.photoImageView.layer.cornerRadius = self.photoImageViewWidth.constant / 2
    }

    func setupCellWith(memberModel: MemberOrderModel, topLineHidden: Bool, bottomLineHidden: Bool) {
        // 消費者看行事曆
        self.topLineView.isHidden = topLineHidden
        self.bottomLineView.isHidden = bottomLineHidden
        self.timeLabel.text = memberModel.orderTime?.subString(from: 11, to: 15)
        self.badgeImageView.isHidden = !(memberModel.isTop ?? false)
        self.nameLabel.text = memberModel.nickName
        self.addressLabel.text = (memberModel.cityName ?? "") + (memberModel.areaName ?? "")
        self.addressLabel.textColor = color_4A4A4A
        self.statusLabel.text = memberModel.orderStatusName
        if let url = memberModel.headerImgUrl, url.count > 0 {
            self.photoImageView.setImage(with: url)
        } else {
            self.photoImageView.image = UIImage(named: "img_account_user")
        }
    }
    
    func setupCellWith(operatingModel: CalendarModel_Operating, topLineHidden: Bool, bottomLineHidden: Bool) {
        self.topLineView.isHidden = topLineHidden
        self.bottomLineView.isHidden = bottomLineHidden
        self.timeLabel.text = operatingModel.orderTime.subString(from: 11, to: 15)
        
        if UserManager.sharedInstance.userIdentity == .designer {
            // 設計師看行事曆
            // 設計師行事曆有兩種：一種是有消費者的訂單,另一種是單純預約場地的訂單
            self.badgeImageView.isHidden = true
            if let member = operatingModel.memberOrder {
                self.nameLabel.text = member.nickName
                self.addressLabel.text = member.placeName
                self.addressLabel.textColor = .black
                self.statusLabel.text = member.orderStatusName
                if let url = member.headerImgUrl, url.count > 0 {
                    self.photoImageView.setImage(with:url)
                } else {
                    self.photoImageView.image = UIImage(named: "img_account_user")
                }
            } else if let provider = operatingModel.designerOrder?.provider {
                self.nameLabel.text = provider.nickName
                self.addressLabel.text = provider.cityName + provider.areaName + provider.address
                self.addressLabel.textColor = color_4A4A4A
                self.statusLabel.text = provider.orderStatusName
                if let url = provider.headerImgUrl, url.count > 0 {
                    self.photoImageView.setImage(with: url)
                } else {
                    self.photoImageView.image = UIImage(named: "img_account_user")
                }
            }
        } else {
            // 場地業者看行事曆
            self.badgeImageView.isHidden = !(operatingModel.designerOrder?.designer?.isTop ?? false)
            self.nameLabel.text = operatingModel.designerOrder?.designer?.nickName
            self.addressLabel.text = (operatingModel.designerOrder?.designer?.cityName ?? "") + (operatingModel.designerOrder?.designer?.areaName ?? "")
            self.addressLabel.textColor = color_4A4A4A
            self.statusLabel.text = operatingModel.designerOrder?.designer?.orderStatusName
            if let url = operatingModel.designerOrder?.designer?.headerImgUrl, url.count > 0 {
                self.photoImageView.setImage(with: url)
            } else {
                self.photoImageView.image = UIImage(named: "img_account_user")
            }
        }
    }
    
}
