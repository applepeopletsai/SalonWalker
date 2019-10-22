//
//  EditServicePriceCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/7/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol EditServicePriceCellDelegate: class {
    func didChangePrice(_ price: Int?, at indexPath: IndexPath)
}

class EditServicePriceCell: UITableViewCell {

    @IBOutlet private weak var priceTextField: UITextField!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private var indexPath: IndexPath?
    private weak var delegate: EditServicePriceCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCellWith(price: Int?, delegate: EditServicePriceCellDelegate, indexPath: IndexPath) {
        if let price = price {
            self.priceTextField.text = String(price)
        }
        self.delegate = delegate
        self.indexPath = indexPath
    }
    
    func setupCellWith(title: String?, price: Int?, delegate: EditServicePriceCellDelegate, indexPath: IndexPath) {
        self.titleLabel.text = title
        if let price = price {
            self.priceTextField.text = String(price)
        }
        self.delegate = delegate
        self.indexPath = indexPath
    }
    
}

extension EditServicePriceCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let totalString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if let totalString = totalString, let indexPath = indexPath {
            self.delegate?.didChangePrice(Int(totalString), at: indexPath)
        }
        return true
    }
}
