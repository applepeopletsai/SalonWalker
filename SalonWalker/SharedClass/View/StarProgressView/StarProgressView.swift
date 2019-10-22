//
//  StarProgressView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/11.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class StarProgressView: UIView {

    private var bottomView: UIView!
    private var progressView: UIView!
    
    override var bounds: CGRect {
        didSet {
            resizeFrame()
        }
    }
    
    @IBInspectable var bottomViewBackgroundColor: UIColor = color_F2F2F2 {
        didSet {
            self.bottomView.backgroundColor = bottomViewBackgroundColor
        }
    }
    
    @IBInspectable var progressViewBackgroundColor: UIColor = color_8F92F5 {
        didSet {
            self.progressView.backgroundColor = progressViewBackgroundColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        
        var frame = self.bounds
        frame.size.width = 0
        
        self.bottomView = UIView(frame: self.bounds)
        self.progressView = UIView(frame: frame)
        
        let cornerRadius = self.bounds.size.height / 2
        self.bottomView.layer.cornerRadius = cornerRadius
        self.progressView.layer.cornerRadius = cornerRadius
        
        self.bottomView.backgroundColor = bottomViewBackgroundColor
        self.progressView.backgroundColor = progressViewBackgroundColor

        self.addSubview(self.bottomView)
        self.addSubview(self.progressView)
    }
    
    private func resizeFrame() {
        if self.bottomView.frame != self.bounds {
            self.bottomView.frame = self.bounds
            
            var frame = self.bounds
            frame.size.width = 0
            self.progressView.frame = frame
        }
    }
    
    func currentValue(_ value: CGFloat) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            var frame = self.bounds
            frame.size.width = (value / 100) * self.bounds.size.width
            self.progressView.frame = frame
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
}
