//
//  TwoButtonTextViewAlertViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/7/10.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class TwoButtonTextViewAlertViewController: BaseViewController {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textView: IBInspectableTextView!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    
    private var image: UIImage?
    private var titleLabelText: String?
    private var leftButtonTitle: String?
    private var rightButtonTitle: String?
    private var textViewBackgroundColor = color_F8F6FF
    private var placeholderLocalizedKey: String?
    private var leftButtonAction: actionClosure?
    private var rightButtonAction: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func setupVCWith(image: UIImage?, title: String?, leftButtonTitle: String?, leftButtonAction: actionClosure?, rightButtonTitle: String?, rightButtonAction: ((String) -> Void)?, textViewPlcaeHolderKey: String?, textViewBackgroundColor: UIColor = color_F8F6FF) {
        self.image = image
        self.titleLabelText = title
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        self.placeholderLocalizedKey = textViewPlcaeHolderKey
        self.textViewBackgroundColor = textViewBackgroundColor
        self.leftButtonAction = leftButtonAction
        self.rightButtonAction = rightButtonAction
    }
    
    private func initialize() {
        self.textView.backgroundColor = textViewBackgroundColor
        self.textView.placeholderLocalizedKey = placeholderLocalizedKey ?? ""
        self.imageView.image = image
        self.titleLabel.text = titleLabelText
        self.leftButton.setTitle(leftButtonTitle, for: .normal)
        self.rightButton.setTitle(rightButtonTitle, for: .normal)
    }
    
    @IBAction private func leftButtonPress(_ sender: UIButton) {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.leftButtonAction?()
        })
    }
    
    @IBAction private func rightButtonPress(_ sender: UIButton) {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.rightButtonAction?(self?.textView.text ?? "")
        })
    }
}

extension TwoButtonTextViewAlertViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.rightButton.isEnabled = (textView.text.count == 0) ? false : true
    }
}
