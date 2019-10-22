//
//  EUATitleCell.swift
//  SalonWalker
//
//  Created by Cooper on 2018/8/28.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol EUATitleCellDelegate: class {
    func addEUATitle(title: String)
}

class EUATitleCell: UICollectionViewCell {
    
    @IBOutlet private weak var titleField: UITextField!
    private weak var delegate: EUATitleCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let placeholderStr = LocalizedString("Lang_PF_007")
        titleField.attributedPlaceholder = NSAttributedString(string: placeholderStr, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        titleField.placeholder = placeholderStr
        // Initialization code
    }
    
    func setupEUATitleDelegate(title: String, delegate: EUATitleCellDelegate) {
        titleField.text = title
        self.delegate = delegate
    }
}

extension EUATitleCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let totalString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string).trimmingCharacters(in: .whitespaces)
        if let totalString = totalString {
            self.delegate?.addEUATitle(title: totalString)
        }
        return true
    }
    
}
