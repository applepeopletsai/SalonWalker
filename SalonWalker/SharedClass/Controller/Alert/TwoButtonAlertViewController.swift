//
//  TwoButtonAlertViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/27.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class TwoButtonAlertViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!

    private var message: String?
    private var image: UIImage?
    private var leftButtonTitle: String?
    private var rightButtonTitle: String?
    private var leftButtonAction: actionClosure?
    private var rightButtonAction: actionClosure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    func setupVCWith(image: UIImage?, message: String, leftButtonTitle: String, leftButtonAction:actionClosure?, rightButtonTitle: String, rightButtonAction: actionClosure?) {
        self.message = message
        self.image = image
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        self.leftButtonAction = leftButtonAction
        self.rightButtonAction = rightButtonAction
    }
    
    private func initialize() {
        self.messageLabel.text = message
        self.imageView.image = image
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
            self?.rightButtonAction?()
        })
    }
}
