//
//  ExtensionTableViewCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    func makeShadowAndCornerRadius() {
        self.contentView.backgroundColor = UIColor.white
        self.contentView.layer.cornerRadius = 6.0
        self.contentView.layer.masksToBounds = true
        
        self.backgroundColor = UIColor.clear
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.22).cgColor
        self.layer.masksToBounds = false
    }
}
