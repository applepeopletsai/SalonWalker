//
//  QRcodeViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/12.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class QRcodeViewController: BaseViewController {

    @IBOutlet private weak var qrcodeImageView: UIImageView!
    
    private var qrcodeUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    func setupVCWith(url: String) {
        self.qrcodeUrl = url
    }
    
    private func initialize() {
        if let url = qrcodeUrl {
            qrcodeImageView.setImage(with: url)
        }
    }
}
