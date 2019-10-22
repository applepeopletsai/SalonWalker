//
//  LocalizedLabel.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/14.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class IBInspectableLabel: UILabel {

    @IBInspectable var titleLocalizedKey: String? {
        didSet {
            if let titleLocalizedKey = titleLocalizedKey {
                self.text = LocalizedString(titleLocalizedKey)
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = .white {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
