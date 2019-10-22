//
//  TextViewPickerViewAlertViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/28.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class TextViewPickerViewAlertViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var itemHintLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var textView: IBInspectableTextView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    private var itemArray: [String]?
    private var selectIndex = -1
    private var message: String?
    private var image: UIImage?
    private var itemHint: String?
    private var textPlaceHolderKey: String?
    private var leftButtonTitle: String?
    private var rightButtonTitle: String?
    private var leftButtonAction: actionClosure?
    private var rightButtonAction: ((String,Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    func setupVCWith(image: UIImage? , message: String?, itemHint: String?, itemArray: [String], textPlaceHolderKey: String?, leftButtonTitle: String?, leftButtonAction: actionClosure?, rightButtonTitle: String?, rightButtonAction: ((String,Int) -> Void)?) {
        self.image = image
        self.message = message
        self.itemHint = itemHint
        self.itemArray = itemArray
        self.textPlaceHolderKey = textPlaceHolderKey
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        self.leftButtonAction = leftButtonAction
        self.rightButtonAction = rightButtonAction
    }

    private func initialize() {
        self.messageLabel.text = message
        self.imageView.image = image
        self.itemHintLabel.text = itemHint
        self.textView.placeholderLocalizedKey = textPlaceHolderKey ?? ""
        self.leftButton.setTitle(leftButtonTitle, for: .normal)
        self.rightButton.setTitle(rightButtonTitle, for: .normal)
    }
    
    @IBAction func itemButtonClick(_ sender: UIButton) {
        textView.resignFirstResponder()
        let index = (selectIndex == -1) ? 0 : selectIndex
        PresentationTool.showPickerWith(itemArray: itemArray, selectedIndex: index, cancelAction: nil, confirmAction: { [unowned self] (item, index) in
            self.itemLabel.text = item
            self.itemLabel.textColor = .black
            self.selectIndex = index
            self.rightButtonEnable(text: self.textView.text, selectIndex: self.selectIndex)
        })
    }
    
    @IBAction func leftButtonClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.leftButtonAction?()
        })
    }
    
    @IBAction func rightButtonClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.rightButtonAction?(self?.textView.text ?? "", self?.selectIndex ?? 0)
        })
    }
    
    private func rightButtonEnable(text: String , selectIndex: Int) {
        if (text.count) != 0 && selectIndex != -1 {
            self.rightButton.isEnabled = true
        } else {
            self.rightButton.isEnabled = false
        }
    }
}

extension TextViewPickerViewAlertViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        rightButtonEnable(text: textView.text, selectIndex: selectIndex)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let totalString = (textView.text as NSString?)?.replacingCharacters(in: range, with: text)
        if let totalString = totalString, totalString.count > 200 {
            return false
        }
        return true
    }
}

