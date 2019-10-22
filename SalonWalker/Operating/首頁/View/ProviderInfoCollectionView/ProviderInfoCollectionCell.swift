//
//  ProviderInfoCollectionCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/6/20.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Cosmos

protocol ProviderInfoCollectionCellDelegate: class {
    func heartButtonClickAt(_ indexPath: IndexPath)
}

class ProviderInfoCollectionCell: UICollectionViewCell {
    
    //MARK: IBOutlet
    @IBOutlet weak var starImage: CosmosView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var peopleCountLabel: UILabel!
    @IBOutlet weak var storeAreaLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var storeImageView: UIImageView!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    
    private var indexPath: IndexPath?
    private weak var delegate: ProviderInfoCollectionCellDelegate?
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.makeShadowAndCornerRadius()
        self.headerImageView.layer.cornerRadius = 15
        self.headerImageView.layer.borderColor = color_3DF9B1.cgColor
        self.headerImageView.layer.borderWidth = 1
    }
    
    // MARK: EventHandler
    @IBAction func heartButtonHandler(_ sender: UIButton) {
        if let indexPath = indexPath {
            self.delegate?.heartButtonClickAt(indexPath)
        }
    }
    
    // MARK: Class Method
    func setupCellWith(indexPath: IndexPath, providerModel: ProviderListModel?, designerModel: DesignerListModel?, delegate: ProviderInfoCollectionCellDelegate) {
        self.delegate = delegate
        self.indexPath = indexPath
        
        if let model = providerModel {
            self.headerImageView.isHidden = true
            self.starImage.rating = model.evaluationAve
            self.storeNameLabel.text = model.nickName
            self.storeAreaLabel.text = String(model.city + "．" + model.area)
            self.heartButton.setImage((model.isFav) ? UIImage(named: "icon_like_active") : UIImage(named: "icon_like_normal"), for: .normal)
            self.peopleCountLabel.text = "(\(model.evaluationTotal))"
            self.priceLabel.attributedText = DetailManager.getPriceStringWith(svcHoursPrices: model.svcHoursPrices, svcTimesPrices: model.svcTimesPrices, svcLeasePrices: model.svcLeasePrices, type: "HomePage")

            if model.coverImgUrl.count > 0 {
                self.storeImageView.setImage(with: model.coverImgUrl)
            } else {
                self.storeImageView.image = UIImage(named: "img_account_user")
            }
        } else if let model = designerModel {
            self.starImage.rating = model.evaluationAve
            self.storeNameLabel.text = model.nickName
            self.storeAreaLabel.text = String(model.experience) + LocalizedString("Lang_RT_015") + "．" + LocalizedString("Lang_HM_016")
            self.heartButton.setImage((model.isFav) ? UIImage(named: "icon_like_active") : UIImage(named: "icon_like_normal"), for: .normal)
            self.peopleCountLabel.text = "(\(model.evaluationTotal))"
            if model.coverImgUrl.count > 0 {
                self.storeImageView.setImage(with: model.coverImgUrl)
            } else {
                self.storeImageView.image = UIImage(named: "img_account_user")
            }
            if let url = model.headerImgUrl, url.count > 0 {
                self.headerImageView.isHidden = false
                self.headerImageView.setImage(with: url)
            } else {
                self.headerImageView.isHidden = true
            }
            
            let priceAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14),
                                  NSAttributedString.Key.foregroundColor: color_2F10A0]
            let itemAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
                                 NSAttributedString.Key.foregroundColor: color_2F10A0]
            let combinAttrString = NSMutableAttributedString()
            let servicePrice = NSAttributedString(string: "$\(model.servicePrice) ", attributes: priceAttribute)
            let serviceItem = NSAttributedString(string: model.serviceItem, attributes: itemAttribute)
            combinAttrString.append(servicePrice)
            combinAttrString.append(serviceItem)
            self.priceLabel.attributedText = combinAttrString
        }
    }
    
    func changeViewAnimation(isFav: Bool) {
        AnimationTool.favImageAnimation(sender: self.heartButton, isFav: isFav)
    }
}
