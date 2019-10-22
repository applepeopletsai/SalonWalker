//
//  ProviderInfoCollectionCell_NoFav.swift
//  SalonWalker
//
//  Created by Daniel on 2018/6/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol ProviderInfoCollectionCell_NoFavDelegate: class {
    func findSiteButtonPress()
}

class ProviderInfoCollectionCell_NoFav: UICollectionViewCell {
    weak var delegate: ProviderInfoCollectionCell_NoFavDelegate?
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }
    
    private func configureCell() {
        if UserManager.sharedInstance.userIdentity == .store {
            self.titleLabel.text = LocalizedString("Lang_AC_074")
            self.button.setTitle(LocalizedString("Lang_HM_018"), for: .normal)
        }
    }
    
    @IBAction private func findSiteButtonPress(_ sender: UIButton) {
        self.delegate?.findSiteButtonPress()
    }
}
