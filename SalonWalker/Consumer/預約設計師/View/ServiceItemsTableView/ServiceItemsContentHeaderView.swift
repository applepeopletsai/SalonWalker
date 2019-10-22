//
//  ServiceItemsContentHeaderView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/10.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ServiceItemsContentHeaderView: UITableViewHeaderFooterView {

    @IBOutlet private weak var serviceItemCollectionView: ServiceItemCollectionView!
    @IBOutlet private weak var totalPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupHeaderViewWith(model: [SvcCategoryModel]) {
        let selectCategory = model.filter{ $0.select ?? false }
        self.serviceItemCollectionView.setupCollectionViewWith(dataArray: selectCategory)
        self.totalPriceLabel.text = "$\(ReservationManager.calculateServiceTotalValue(selectCategory: selectCategory, type: .Price).transferToDecimalString())"
    }

}
