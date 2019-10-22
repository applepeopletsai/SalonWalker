//
//  ServiceItemHeaderView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/7/12.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ServiceItemHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var serviceItmeNameLabel: UILabel!
    @IBOutlet private weak var serviceIconImageView: UIImageView!
    @IBOutlet private weak var arrowImageView: UIImageView!
    
    func setupHeaderViewWith(model: ServiceItemModel, section: Int) {
        titleLabel.isHidden = (section == 0) ? false : true
        serviceItmeNameLabel.text = model.itemTitle
        serviceIconImageView.setImage(with: model.iconImgUrl)
        arrowImageView.isHidden = (model.product?.count == 0)
        arrowImageView.image = (model.expand) ? UIImage(named: "nav_arrow_top") : UIImage(named: "nav_arrow_bottom")
        tag = section
    }
}
