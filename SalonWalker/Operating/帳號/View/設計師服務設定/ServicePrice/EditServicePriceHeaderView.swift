//
//  EditServicePriceHeaderView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/7/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol EditServicePriceHeaderViewDelegate: class {
    func didTapTickButtonAt(_ section: Int)
    func didTapPhotoButtonAt(_ section: Int)
}

class EditServicePriceHeaderView: UITableViewHeaderFooterView {

    @IBOutlet private weak var tickImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var photoImageView: UIImageView!

    private var section: Int = 0
    private var model: SvcClassModel?
    private weak var delegate: EditServicePriceHeaderViewDelegate?
    
    func setupHeaderWith(model: SvcClassModel, section: Int, delegate: EditServicePriceHeaderViewDelegate) {
        self.titleLabel.text = model.name
        self.tickImageView.image = (model.open ?? false) ? UIImage(named: "checkbox_checked") : UIImage(named: "checkbox_normal")
        if let product = model.svcProduct?.first, let url = product.imgUrl {
            self.photoImageView.setImage(with: url)
        } else {
            self.photoImageView.image = UIImage(named: "btn_image")
        }
        self.model = model
        self.section = section
        self.delegate = delegate
    }
    
    @IBAction private func tickButtonPress(_ sender: UIButton) {
        if let open = self.model?.open {
            self.model?.open = !open
            self.tickImageView.image = (!open) ? UIImage(named: "checkbox_checked") : UIImage(named: "checkbox_normal")
            self.delegate?.didTapTickButtonAt(self.section)
        }
    }
    
    @IBAction private func photoButtonPress(_ sender: UIButton) {
        self.delegate?.didTapPhotoButtonAt(self.section)
    }
}
