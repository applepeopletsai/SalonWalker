//
//  TextViewAlertViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/27.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class TextViewAlertViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var button: UIButton!
    
    private var titleLabelText: String?
    private var image: UIImage?
    private var textViewText: String?
    private var buttonTitle: String?
    private var buttonAction: actionClosure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func setupVCWith(image: UIImage?, title: String?, textViewText: String?, buttonTitle: String?, buttonAction: actionClosure?) {
        self.buttonAction = buttonAction
        self.titleLabelText = title
        self.image = image
        self.textViewText = textViewText
        self.buttonTitle = buttonTitle
    }
    
    private func initialize() {
        self.textView.text = textViewText ?? ""
        self.imageView.image = image
        self.titleLabel.text = title
        self.button.setTitle(buttonTitle, for: .normal)
    }
    
    @IBAction private func buttonPress(_ sender: UIButton) {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.buttonAction?()
        })
    }
}
