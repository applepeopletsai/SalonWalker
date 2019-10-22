//
//  EUACommentCell.swift
//  SalonWalker
//
//  Created by Cooper on 2018/8/28.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol EUACommentCellDelegate: class {
    func addEUAComment(comment: String)
}

class EUACommentCell: UICollectionViewCell {
    
    @IBOutlet private weak var textView: UITextView!
    
    private weak var delegate: EUACommentCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupEUACommentDelegate(comment: String?, delegate: EUACommentCellDelegate) {
        self.delegate = delegate
        if let comment = comment {
            textView.text = comment
        }
    }
    
}

extension EUACommentCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let inputString = (textView.text as NSString?)?.replacingCharacters(in: range, with: text).trimmingCharacters(in: .whitespaces)
        if let inputString = inputString {
            self.delegate?.addEUAComment(comment: inputString)
        }
        return true
    }
}
