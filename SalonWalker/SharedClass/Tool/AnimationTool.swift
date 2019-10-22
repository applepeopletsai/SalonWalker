//
//  AnimationTool.swift
//  SalonWalker
//
//  Created by Daniel on 2018/7/24.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class AnimationTool {
    static func favImageAnimation(sender: UIButton, isFav: Bool) {
        CATransaction.flush()
        UIView.transition(with: sender, duration: 0.3, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: {
            sender.setImage((isFav) ? UIImage(named: "icon_like_active") : UIImage(named: "icon_like_normal"), for: .normal)
            }, completion: nil)
    }
}
