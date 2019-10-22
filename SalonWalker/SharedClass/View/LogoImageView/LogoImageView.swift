//
//  LogoImageView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/12/20.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class LogoImageView: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.image = UIImage(named: (SystemManager.getAppIdentity() == .SalonWalker) ? "logo_salon_walker_132x132" : "img_logo_maker")
    }

}
