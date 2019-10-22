//
//  DeviceCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/7.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol DeviceCellDelegate: class {
    func textFieldDidEndEditing(text: String?, row: Int)
}

class DeviceCell: UITableViewCell {

    @IBOutlet private weak var selectImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var countTextField: UITextField!
    @IBOutlet private weak var countLabel: UILabel!
    
    private var row: Int = 0
    private weak var delegate: DeviceCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCellWith(model: EquipmentItemModel.Equipment, row: Int, target: DeviceCellDelegate) {
        self.delegate = target
        self.row = row
        self.countTextField.isHidden = !model.permitQuantity
        self.countLabel.isHidden = !model.permitQuantity
        self.selectImageView.isHidden = !model.selected
        self.titleLabel.text = model.name
        self.countTextField.text = String(model.count)
    }
    
    func textFieldBecomeFirstResponder() {
        self.countTextField.becomeFirstResponder()
    }
}

extension DeviceCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text, text == "0" {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == nil || textField.text?.count == 0 {
            textField.text = "0"
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let totalString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if let totalString = totalString {
            self.delegate?.textFieldDidEndEditing(text: totalString, row: row)
        }
        return true
    }
}


