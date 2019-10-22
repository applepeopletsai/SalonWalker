//
//  ImagePageControll.swift
//  SalonWalker
//
//  Created by Daniel on 2018/5/11.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ImagePageControll: UIPageControl {

    private var activeImage: UIImage?
    private var inactiveImage: UIImage?
    
    init(frame: CGRect, activeImage: String, inactiveImage: String, currnetPage: Int = 0, numberOfPages: Int) {
        super.init(frame: frame)
        
        self.activeImage = UIImage(named: activeImage)
        self.inactiveImage = UIImage(named: inactiveImage)
        self.currentPage = currnetPage
        self.numberOfPages = numberOfPages
        self.updateDots()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCurrentPage(_ currentPage: Int) {
        super.currentPage = currentPage
        self.updateDots()
    }
    
    private func updateDots() {
        for i in 0..<self.subviews.count {
            let dot = self.imageViewForSubViews(self.subviews[i])
            dot?.image = (i == self.currentPage) ? self.activeImage : self.inactiveImage
        }
    }
    
    private func imageViewForSubViews(_ view: UIView) -> UIImageView? {
        
        var dot: UIImageView?
        
        if view is UIImageView {
            dot = view as? UIImageView
        } else {
            for subview in view.subviews {
                if subview is UIImageView {
                    dot = subview as? UIImageView
                    break
                }
            }
            if dot == nil {
                dot = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
                view.addSubview(dot!)
            }
        }
        return dot
    }
    
}


