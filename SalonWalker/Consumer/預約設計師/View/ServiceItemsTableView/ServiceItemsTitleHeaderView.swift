//
//  ServiceItemsTitleHeaderView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/10.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol ServiceItemsTitleHeaderViewDelegate: class {
    func didTapAt(_ section: Int)
    func didSelectAt(_ section: Int)
}

class ServiceItemsTitleHeaderView: UITableViewHeaderFooterView {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var serviceNameLabel: UILabel!
    @IBOutlet private weak var checkBoxButton: UIButton!
    
    private weak var delegate: ServiceItemsTitleHeaderViewDelegate?
    private var section: Int?
    
    func setupHeaderViewWith(model: SvcCategoryModel, section: Int, delegate: ServiceItemsTitleHeaderViewDelegate?) {
        self.section = section
        self.delegate = delegate
        self.serviceNameLabel.text = model.name
        self.checkBoxButton.isSelected = (model.select ?? false)
        if let url = model.iconUrl {
            self.iconImageView.setImage(with: url)
        } else {
            self.iconImageView.image = nil
        }
    }
    
    // MARK: Event Handler
    @IBAction private func viewButtonPress(_ sender: UIButton) {
        
    }
    
    @IBAction private func checkBoxButtonPress(_ sender: UIButton) {
        if let section = section {
            self.delegate?.didSelectAt(section)
        }
    }
}
