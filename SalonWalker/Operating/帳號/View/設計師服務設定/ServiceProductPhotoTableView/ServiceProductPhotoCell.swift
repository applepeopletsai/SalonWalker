//
//  ServiceProductPhotoCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/12.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Photos

protocol ServiceProductPhotoCellDelegate: class {
    func deleteButtonPressAtIndexPath(_ indexPath: IndexPath)
    func didUpdateData(productBrand: String?, productName: String?, indexPath: IndexPath)
}

class ServiceProductPhotoCell: UITableViewCell {

    @IBOutlet private weak var productBrandTextField: UITextField!
    @IBOutlet private weak var productNameTextField: UITextField!
    @IBOutlet private weak var productImageView: UIImageView!
    
    private var indexPath: IndexPath?
    private weak var delegate: ServiceProductPhotoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCellWith(model: SvcProductModel, indexPath: IndexPath, delegate: ServiceProductPhotoCellDelegate?) {
        self.indexPath = indexPath
        self.delegate = delegate
        
        self.productBrandTextField.text = model.brand
        self.productNameTextField.text = model.product
        
        if let localIdentifier = model.imageLocalIdentifier {
            let phAssets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
            if let asset = phAssets.firstObject {
                MultipleAsset(originalAsset: asset).fetchOriginalImage { (image, info) in
                    self.productImageView.image = image
                }
            }
        } else if let url = model.imgUrl {
            self.productImageView.setImage(with: url)
        } else {
            self.productImageView.image = nil
        }
    }
    
    @IBAction private func deleteButtonPress(_ sender: UIButton) {
        
        SystemManager.showTwoButtonAlertWith(alertTitle: LocalizedString("Lang_AC_054") + "？", alertMessage: nil, leftButtonTitle: LocalizedString("Lang_GE_060"), rightButtonTitle: LocalizedString("Lang_GE_056"), leftHandler: nil, rightHandler: { [unowned self] in
            if let indexPath = self.indexPath {
                self.delegate?.deleteButtonPressAtIndexPath(indexPath)
            }
        })
    }
    
}

extension ServiceProductPhotoCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let indexPath = indexPath {
            self.delegate?.didUpdateData(productBrand: productBrandTextField.text, productName: productNameTextField.text, indexPath: indexPath)
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let totalString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        var brand = productBrandTextField.text
        var productName = productNameTextField.text
        if textField == productBrandTextField {
            brand = totalString
        }
        if textField == productNameTextField {
            productName = totalString
        }
        if let indexPath = indexPath {
            self.delegate?.didUpdateData(productBrand: brand, productName: productName, indexPath: indexPath)
        }
        return true
    }
}

