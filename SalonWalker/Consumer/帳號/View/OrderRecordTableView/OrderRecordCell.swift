//
//  OrderRecordCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/16.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol OrderRecordCellDelegate: class {
    func commentButtonPressAtIndexPath(_ indexPath: IndexPath)
}

class OrderRecordCell: UITableViewCell {

    @IBOutlet private weak var orderNoLabel: UILabel!
    @IBOutlet private weak var badgeImageView: UIImageView!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var storeNameLabel: UILabel!
    @IBOutlet private weak var payTimeLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var commentButton: IBInspectableButton!
    
    private var indexPath: IndexPath?
    private weak var delegate: OrderRecordCellDelegate?
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.x += 15
            frame.origin.y += 5
            frame.size.width -= 30
            frame.size.height -= 10
            super.frame = frame
            self.makeShadowAndCornerRadius()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWith(model: OrderListModel.OrderList, indexPath: IndexPath, delegate: OrderRecordCellDelegate?) {
        self.indexPath = indexPath
        self.delegate = delegate
        
        self.badgeImageView.isHidden = !(model.isTop ?? false)
        self.orderNoLabel.text = "\(LocalizedString("Lang_RD_005"))：\(model.orderNo)"
        self.nameLabel.text = model.nickName
        self.cityLabel.text = "\(model.cityName ?? "") \(model.langName ?? "")"
        self.storeNameLabel.text = model.placeName
        self.statusLabel.text = "(\(model.orderStatusName))"
        if let url = model.headerImgUrl, url.count > 0 {
            self.photoImageView.setImage(with: url)
        } else {
            self.photoImageView.image = UIImage(named: "img_account_user")
        }
        if model.orderStatus == 4 ||
            model.orderStatus == 5 ||
            model.orderStatus == 6 { // 已完成
            self.payTimeLabel.text = "\(model.finishTime.subString(from: 0, to: 15)) \(LocalizedString("Lang_RD_037"))"
            self.priceLabel.text = "$\((model.deposit + model.finalPayment).transferToDecimalString())"
            self.commentButton.isHidden = false
            
            self.commentButton.setTitle(model.evaluateStatus.statusName, for: .normal)
            self.commentButton.setImage(UIImage(named: (model.evaluateStatus.evaluation == nil) ? "btn_bubble_n_20x18" : "btn_bubble_selected_20x18"), for: .normal)
        } else {
            self.payTimeLabel.text = "\(model.payTime.subString(from: 0, to: 15)) \(LocalizedString("Lang_RD_038"))"
            self.priceLabel.text = "$\(model.deposit.transferToDecimalString())"
            self.commentButton.isHidden = true
        }
        if model.orderStatus == 7 ||
            model.orderStatus == 8 ||
            model.orderStatus == 9 ||
            model.orderStatus == 10 { // 已退訂金、已罰款
            self.priceLabel.textColor = color_9B9B9B
        } else {
            self.priceLabel.textColor = .black
        }
    }
    
    @IBAction private func commentButtonPress(_ sender: UIButton) {
        if let indexPath = indexPath {
            self.delegate?.commentButtonPressAtIndexPath(indexPath)
        }
    }
}
