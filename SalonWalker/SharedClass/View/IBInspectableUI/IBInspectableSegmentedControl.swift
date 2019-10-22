//
//  IBInspectableSegmentedControl.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/29.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class IBInspectableSegmentedControl: UISegmentedControl {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
            self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderColor: UIColor = .white {
        didSet {
            self.layer.borderColor = borderColor.cgColor
            self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var titles: String? {
        didSet {
            if let titles = titles {
                let array = titles.components(separatedBy: ",")
                for i in 0..<array.count {
                    self.setTitle(LocalizedString(array[i]), forSegmentAt: i)
                }
            }
        }
    }

}
