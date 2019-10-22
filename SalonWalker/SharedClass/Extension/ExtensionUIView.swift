//
//  ExtensionUIView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/8.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

extension UIView {
    func addSublayer(layers: [CALayer]) {
        for layer in layers {
            self.layer.addSublayer(layer)
        }
    }
    
    func removeAllSublayers() {
        guard let layers = self.layer.sublayers else { return }
        for layer in layers {
            layer.removeFromSuperlayer()
        }
    }
    
    func removeAllSubviews() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    
    func removeAllGestureRecognizer() {
        for subview in self.subviews {
            for ges in subview.gestureRecognizers ?? [] {
                subview.removeGestureRecognizer(ges)
            }
        }
    }
}
