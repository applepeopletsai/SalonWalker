//
//  NearByCollectionViewCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Cosmos

protocol NearByCollectionViewCellDelegate: class {
    func reservationButtonPressAt(_ indexPath: IndexPath)
    func favoriteButtonPressAt(_ indexPath: IndexPath)
}

class NearByCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var designerImageView: UIImageView!
    @IBOutlet private weak var designerNameLabel: UILabel!
    @IBOutlet private weak var distanceImageView: UIImageView!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var jobTitleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var serviceItemLabel: UILabel!
    @IBOutlet private weak var starView: CosmosView!
    @IBOutlet private weak var evaluationLabel: UILabel!
    @IBOutlet private weak var starViewWidth: NSLayoutConstraint!
    @IBOutlet private weak var starViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var portfolioImageView: UIImageView!
    @IBOutlet private weak var badgeImageView: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    
    private weak var delegate: NearByCollectionViewCellDelegate?
    private var indexPath: IndexPath?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        starView.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.makeShadowAndCornerRadius()
        self.setupStarView()
        self.resizeLabelFont()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        setupImageViewCornerRadius()
    }
    
    private func setupStarView() {
        var starSize: Double = 16
        
        if SizeTool.isIphone5() {
            starSize = 12
        } else if SizeTool.isIphone6Plus() {
            starSize = 18
        }
        
        starView.settings.starSize = starSize
        starViewWidth.constant = starView.frame.size.width
        starViewHeight.constant = starView.frame.size.height
    }
    
    
    private func resizeLabelFont() {
        if SizeTool.isIphone5() {
            let font = UIFont.systemFont(ofSize: 11)
            self.yearLabel.font = font
            self.jobTitleLabel.font = font
        }
    }
    
    private func setupImageViewCornerRadius() {
        self.designerImageView.layer.cornerRadius = self.designerImageView.bounds.size.width / 2
    }
    
    func setupCellWith(model: DesignerListModel, indexPath: IndexPath, delegate: NearByCollectionViewCellDelegate) {
        self.delegate = delegate
        self.indexPath = indexPath
        
        if let url = model.headerImgUrl, url.count > 0 {
            self.designerImageView.setImage(with: url)
        } else {
            self.designerImageView.image = UIImage(named: "img_account_user")
        }
        self.portfolioImageView.setImage(with: model.coverImgUrl)
        self.designerNameLabel.text = model.nickName
        self.yearLabel.text = String(model.experience) + LocalizedString("Lang_RT_015") + "．" + LocalizedString("Lang_HM_016")
        self.jobTitleLabel.text = model.licenseName
        self.priceLabel.text = "$\(model.servicePrice)"
        self.serviceItemLabel.text = "\(LocalizedString("Lang_HM_020"))/\(model.serviceItem)"
        self.starView.rating = model.evaluationAve
        self.badgeImageView.isHidden = !model.isTop
        self.evaluationLabel.text = "(\(model.evaluationTotal))"
        self.likeButton.setImage((model.isFav) ? UIImage(named: "icon_like_active") :UIImage(named: "icon_like_normal"), for: .normal)
        if LocationManager.getAuthorizationStatus() == .authorizedAlways || LocationManager.getAuthorizationStatus() == .authorizedWhenInUse {
            self.distanceImageView.isHidden = false
            self.distanceLabel.isHidden = false
            let distance = model.distance * 1000
            self.distanceLabel.text = (distance > 1000) ? String(format: "%.1f", model.distance) + "km" : String(format: "%.0f", distance) + "m"
        } else {
            self.distanceImageView.isHidden = true
            self.distanceLabel.isHidden = true
        }
    }
    
    func changeViewAnimation(isFav: Bool) {
        AnimationTool.favImageAnimation(sender: self.likeButton, isFav: isFav)
    }
    
    @IBAction private func reservationButtonPress(_ sender: UIButton) {
        if let indexPath = self.indexPath {
            self.delegate?.reservationButtonPressAt(indexPath)
        }
    }
    
    @IBAction private func favoriteButtonPress(_ sender: UIButton) {
        if let indexPath = self.indexPath {
            self.delegate?.favoriteButtonPressAt(indexPath)
        }
    }
}
