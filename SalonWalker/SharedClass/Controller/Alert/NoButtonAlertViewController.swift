//
//  NoButtonAlertViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/27.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class NoButtonAlertViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var imageViewTopConstraint: NSLayoutConstraint!
    
    private var message: String?
    private var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    func setupVCWith(image: UIImage?, message: String) {
        self.message = message
        self.image = image
    }
    
    private func initialize() {
        self.messageLabel.text = message
        self.imageView.image = image
        
        if image == nil { self.imageViewTopConstraint.constant = 0 }
    }
}
