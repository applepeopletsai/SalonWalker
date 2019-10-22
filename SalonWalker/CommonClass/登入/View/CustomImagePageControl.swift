//
//  CustomImagePageControl.swift
//  SalonWalker
//
//  Created by skywind on 2018/3/1.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class CustomImagePageControl: UIPageControl {
    let activeImage:UIImage = UIImage(named: "icon_steps_scissor_active")!
    let inactiveImage:UIImage = UIImage(named: "icon_steps_scissor_normal")!
    
    override var numberOfPages: Int {
        didSet {
            updateDots()
        }
    }
    
    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.pageIndicatorTintColor = UIColor.clear
        self.currentPageIndicatorTintColor = UIColor.clear
        self.clipsToBounds = false
    }

    func updateDots() {
//        self.setValue(activeImage, forKeyPath: "_currentPageImage")
//        self.setValue(inactiveImage, forKeyPath: "_pageImage")
        var i = 0
        for view in self.subviews {
            if let imageView = self.imageForSubview(view) {
                if i == self.currentPage {
                    imageView.image = self.activeImage
                } else {
                    imageView.image = self.inactiveImage
                }
                i = i + 1
                imageView.contentMode = .center
            } else {
                var dotImage = self.inactiveImage
                if i == self.currentPage {
                    dotImage = self.activeImage
                }
                let imageView = UIImageView(image:dotImage)
                imageView.contentMode = .center
                view.clipsToBounds = false
                view.addSubview(imageView)
                i = i + 1
            }
        }
    }
    
    fileprivate func imageForSubview(_ view:UIView) -> UIImageView? {
        var dot:UIImageView?
        
        if let dotImageView = view as? UIImageView {
            dot = dotImageView
        } else {
            for foundView in view.subviews {
                if let imageView = foundView as? UIImageView {
                    dot = imageView
                    break
                }
            }
        }
        
        return dot
    }
}
