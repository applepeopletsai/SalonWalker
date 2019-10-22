//
//  SiteReservationCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/23.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol SiteReservationCellDelegate: class {
    func commentButtonPressAtIndexPath(_ indexPath: IndexPath)
}

class SiteReservationCell: UITableViewCell {

    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var commentView: UIView!
    @IBOutlet private weak var commentButton: IBInspectableButton!
    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var customerView: UIView!
    @IBOutlet private weak var orderNoLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var phoneLabel: UILabel!
    @IBOutlet private weak var customerLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var payTimeLabel: UILabel!
    
    private var indexPath: IndexPath?
    private weak var delegate: SiteReservationCellDelegate?
    
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
    
    func setupCellWith(model: OrderListModel.OrderList, indexPath: IndexPath, delegate: SiteReservationCellDelegate?) {
        self.delegate = delegate
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
        
        // 已預訂為SiteReservationCell_NoPrice class
        /*
         訂單狀態：
         已退訂金  => orderSataus : 4
         已罰緩  => orderSataus : 5
         已完成  => orderSataus : 3
         */
        self.configurePaymentAndCommentView(model: model, finish: (model.orderStatus == 3), cancel: (model.orderStatus == 4 || model.orderStatus == 5))
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
    
    // MARK: Event Handler
    @IBAction func commentButtonClick(_ sender: UIButton) {
        if let indexPath = indexPath {
            self.delegate?.commentButtonPressAtIndexPath(indexPath)
        }
    }
    
}
