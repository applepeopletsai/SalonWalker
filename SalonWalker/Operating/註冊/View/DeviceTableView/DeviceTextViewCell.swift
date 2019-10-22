//
//  DeviceTextViewCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/5/3.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol DeviceTextViewCellDelegate: class {
    func textViewDidEndEditing(text: String?, row: Int)
}

class DeviceTextViewCell: UITableViewCell {

    @IBOutlet private weak var selectImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    
    private var row: Int = 0
    private weak var delegate: DeviceTextViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWith(model: EquipmentItemModel.Equipment, row: Int, target: DeviceTextViewCellDelegate?) {
        self.delegate = target
        self.row = row
        self.titleLabel.text = model.name
        self.textView.text = model.content
        self.selectImageView.isHidden = !model.selected
    }
    
    func textViewBecomeFirstResponder() {
        self.textView.becomeFirstResponder()
    }
}

extension DeviceTextViewCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.textViewDidEndEditing(text: textView.text, row: row)
    }
}
