//
//  NearByTableViewCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class NearByTableViewCell: UITableViewCell {

    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var designerNameLabel: UILabel!
    @IBOutlet private weak var serviceItemLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var evaluationAveLabel: UILabel!
    @IBOutlet private weak var distanceViewWidth: NSLayoutConstraint!
    
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
        // Initialization code
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        setupImageViewCornerRadius()
    }
    
    private func setupImageViewCornerRadius() {
        self.photoImageView.layer.cornerRadius = self.photoImageView.bounds.size.width / 2
    }

    func setupCellWithModel(_ model: DesignerListModel) {
        if let url = model.headerImgUrl, url.count > 0 {
            self.photoImageView.setImage(with: url)
        } else {
            self.photoImageView.image = UIImage(named: "img_account_user")
        }
        self.designerNameLabel.text = model.nickName
        self.serviceItemLabel.text = "$\(model.servicePrice) \(LocalizedString("Lang_HM_020"))/\(model.serviceItem)"
        self.evaluationAveLabel.text = String(model.evaluationAve)
        if LocationManager.getAuthorizationStatus() == .authorizedAlways || LocationManager.getAuthorizationStatus() == .authorizedWhenInUse {
            self.distanceViewWidth.constant = 60
            let distance = model.distance * 1000
            self.distanceLabel.text = (distance > 1000) ? String(format: "%.1f", model.distance) + "km" : String(format: "%.0f", distance) + "m"
        } else {
            self.distanceViewWidth.constant = 0
        }
    }
    
}
