//
//  ServiceLocationCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/13.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum ServiceLocationCellType {
    case normal, edit
}

protocol ServiceLocationCellDelegate: class {
    func tickButtonPress(at indexPath: IndexPath)
}

class ServiceLocationCell: UITableViewCell {

    @IBOutlet private weak var storeImageView: UIImageView!
    @IBOutlet private weak var storeNameLabel: UILabel!
    @IBOutlet private weak var storeAddressLabel: UILabel!
    @IBOutlet private weak var tickButton: UIButton!
    @IBOutlet private weak var tickButtonWidth: NSLayoutConstraint!
    
    private var indexPath: IndexPath?
    private weak var delegate: ServiceLocationCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.storeImageView.layer.cornerRadius = self.storeImageView.bounds.width / 2
    }

    // MARK: Method
    func setupCellWith(model: SvcPlaceModel, indexPath: IndexPath, cellType: ServiceLocationCellType, delegate: ServiceLocationCellDelegate) {
        self.delegate = delegate
        self.indexPath = indexPath
        self.storeNameLabel.text = model.nickName
        self.storeAddressLabel.text = (model.cityName ?? "") + (model.areaName ?? "") + (model.address ?? "")
        self.tickButton.setImage( (model.select!) ? UIImage(named: "checkbox_checked_20x20") : UIImage(named: "checkbox_normal_20x20"), for: .normal)
        self.tickButtonWidth.constant = (cellType == .normal) ? 0 : 50
        if let url = model.headerImgUrl, url.count > 0 {
            self.storeImageView.setImage(with: url)
        } else {
            self.storeImageView.image = UIImage(named: "img_account_user")
        }
    }
    
    func animateTickButtonImage(cellType: ServiceLocationCellType) {
        self.tickButtonWidth.constant = (cellType == .normal) ? 0 : 50
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    // MARK: Event Handler
    @IBAction func tickButtonClick(_ sender: UIButton) {
        if let indexPath = indexPath {
            self.delegate?.tickButtonPress(at: indexPath)
        }
    }
}


