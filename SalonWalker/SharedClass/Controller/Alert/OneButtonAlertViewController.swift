//
//  OneButtonAlertViewController.swift
//  SalonWalker
//
//  Created by skywind on 2018/2/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class OneButtonAlertViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!
    
    private var message: String?
    private var image: UIImage?
    private var buttonTitle: String?
    private var buttonAction: actionClosure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    func setupVCWith(image: UIImage?, message: String, buttonTitle: String, buttonAction:actionClosure?) {
        self.message = message
        self.image = image
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
    
    private func initialize() {
        self.messageLabel.text = message
        self.imageView.image = image
        self.actionButton.setTitle(buttonTitle, for: .normal)
    }
    
    @IBAction private func buttonPress(_ sender: UIButton) {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.buttonAction?()
        })
    }

}
