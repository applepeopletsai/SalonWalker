//
//  CustomerReservationCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/23.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol CustomerReservationCellDelegate: class {
    func commentButtonPressAtIndexPath(_ indexPath: IndexPath)
}

class CustomerReservationCell: UITableViewCell {

    @IBOutlet private weak var orderNoLabel: UILabel!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var badgeImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var storeNameLabel: UILabel!
    @IBOutlet private weak var payTimeLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var commentButton: IBInspectableButton!
    @IBOutlet private weak var commentView: UIView!
    @IBOutlet private weak var storeNameView: UIView!
    @IBOutlet private weak var storeNameViewHeight: NSLayoutConstraint!
    
    private weak var delegate: CustomerReservationCellDelegate?
    private var indexPath: IndexPath?
    
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
    func setupCellWith(model: OrderListModel.OrderList, indexPath: IndexPath, delegate: CustomerReservationCellDelegate?) {
        self.indexPath = indexPath
        self.delegate = delegate
        
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

        if UserManager.sharedInstance.userIdentity == .designer {
            // 客戶預約訂單(設計師查看消費者訂單, API:OD004)
            // 待回覆為CustomerReservationCell_NoPrice class
            /* 訂單狀態：
             已收訂金  => orderStatus : 2 / 3 / 12
             已取消  => orderStatus : 7 / 8 / 9 / 10
             已完成  => orderStatus : 4 / 5 / 6
             */
            self.badgeImageView.isHidden = true
            
            if let placeName = model.placeName, placeName.count > 0 {
                self.storeNameView.isHidden = false
                self.storeNameViewHeight.constant = 15
                self.storeNameLabel.text = placeName
            } else {
                self.storeNameView.isHidden = true
                self.storeNameViewHeight.constant = 0
            }
            self.configurePaymentAndCommentView(model: model, finish: (model.orderStatus == 4 || model.orderStatus == 5 || model.orderStatus == 6), cancel: (model.orderStatus == 7 || model.orderStatus == 8 || model.orderStatus == 9 || model.orderStatus == 10 ))
        } else {
            // 設計師預約訂單(場地查看設計師訂單, API:OD006)
            /* 訂單狀態：
             已預定  => orderSataus : 1 / 2
             已取消  => orderSataus : 4 / 5
             已完成  => orderSataus : 3
             */
            self.badgeImageView.isHidden = !(model.isTop ?? false)
            self.storeNameView.isHidden = true
            self.storeNameViewHeight.constant = 0
            self.configurePaymentAndCommentView(model: model, finish: (model.orderStatus == 3), cancel: (model.orderStatus == 4 || model.orderStatus == 5))
        }
    }
    
    private func configurePaymentAndCommentView(model: OrderListModel.OrderList, finish: Bool, cancel: Bool) {
        if finish {
            self.commentView.isHidden = (model.evaluateStatus.evaluation == nil)
            self.commentButton.setImage(UIImage(named: "btn_bubble_selected_20x18"), for: .normal)
            self.commentButton.setTitle(model.evaluateStatus.statusName, for: .normal)
            self.payTimeLabel.text = "\(model.finishTime.subString(from: 0, to: 15)) \(LocalizedString("Lang_RD_037"))"
            self.priceLabel.text = "$\((model.deposit + model.finalPayment).transferToDecimalString())"
        } else {
            self.commentView.isHidden = true
            self.payTimeLabel.text = "\(model.payTime.subString(from: 0, to: 15)) \(LocalizedString("Lang_RD_038"))"
            self.priceLabel.text = "$\(model.deposit.transferToDecimalString())"
        }
        self.priceLabel.textColor = cancel ? color_9B9B9B : .black
    }
    
    // MARK: EventHandler
    @IBAction func commentButtonClick(_ sender: UIButton) {
        if let indexPath = indexPath {
            self.delegate?.commentButtonPressAtIndexPath(indexPath)
        }
    }
}
