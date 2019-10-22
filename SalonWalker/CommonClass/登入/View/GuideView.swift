//
//  GuidView.swift
//  SalonWalker
//
//  Created by skywind on 2018/2/27.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class GuideView: UIView ,UIScrollViewDelegate, IntroductionViewDelegate {
    
    var pageControl : UIPageControl?
    let pageControlHeight = 100
    let pageControlWidth = 100
    let closeButtonWidth = 150.0
    let closeButtonHeight = 40.0
    var imageNames = [""]
    
    var dotImageView = [UIImageView]()
    
    class func showGouid() {
        let guideView = GuideView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        guideView.show()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    convenience init(type:AppIdentity) {
        self.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        var titleString = [""]
        var subtitleString = [""]
        if type == .SalonWalker {
            imageNames = ["img_welcome_consumer_01","img_welcome_consumer_02","img_welcome_consumer_03","img_welcome_consumer_04"]
            titleString = [LocalizedString("Lang_WE_001"),LocalizedString("Lang_WE_002"),LocalizedString("Lang_WE_003"),LocalizedString("Lang_WE_004")]
            subtitleString = [LocalizedString("Lang_WE_005"),LocalizedString("Lang_WE_006"),LocalizedString("Lang_WE_007"),LocalizedString("Lang_WE_008")]
        } else {
            imageNames = ["img_welcome01","img_welcome02","img_welcome03","img_welcome04","img_welcome05"]
            titleString = [LocalizedString("Lang_WE_009"),LocalizedString("Lang_WE_010"),LocalizedString("Lang_WE_011"),LocalizedString("Lang_WE_012"),LocalizedString("Lang_WE_004")]
            subtitleString = [LocalizedString("Lang_WE_013"),LocalizedString("Lang_WE_014"),LocalizedString("Lang_WE_015"),LocalizedString("Lang_WE_016"),LocalizedString("Lang_WE_017")]
        }
        backgroundColor = .white
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: self.bounds.size.width * CGFloat(imageNames.count), height: self.bounds.size.height)
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        for index in 0..<imageNames.count {
            let introductionView = IntroductionView.getGuideView(titleString: titleString[index], subtitleString: subtitleString[index], image: UIImage(named:imageNames[index]), type: type,index:index)
            if index == imageNames.count - 1 {
                introductionView?.actionButton.isHidden = false
                introductionView?.delegate = self
            }
            scrollView.addSubview(introductionView!)
        }
        
        let bottomSpace: CGFloat = 40.0
        let height: CGFloat = 40.0
        let y = screenHeight - height - bottomSpace
        let leading: CGFloat = (screenWidth - height * CGFloat(imageNames.count)) / 2
        let pageDotView = UIView(frame: CGRect(x: 0, y: y, width: height, height: height))
        
        for i in 0..<imageNames.count {
            let imageView = UIImageView(frame: CGRect(x: leading + height * CGFloat(i), y: 0, width: height, height: height))
            imageView.image = (i == 0) ? UIImage(named: "icon_steps_scissor_active") : UIImage(named: "icon_steps_scissor_normal")
            imageView.contentMode = .scaleAspectFill
            pageDotView.addSubview(imageView)
            dotImageView.append(imageView)
        }
        
//        pageControl = UIPageControl(frame: CGRect(x: (bounds.size.width - CGFloat(pageControlWidth)) / 2.0, y: bounds.size.height - CGFloat(pageControlHeight), width: CGFloat(pageControlWidth), height: CGFloat(pageControlHeight)))
//        pageControl!.numberOfPages = imageNames.count
//        pageControl!.currentPage = 0
//        let activeImage:UIImage = UIImage(named: "icon_steps_scissor_active")!
//        let inactiveImage:UIImage = UIImage(named: "icon_steps_scissor_normal")!
//
//        pageControl!.setValue(activeImage, forKeyPath: "_currentPageImage")
//        pageControl!.setValue(inactiveImage, forKeyPath: "_pageImage")

        addSubview(scrollView)
//        addSubview(pageControl!)
        addSubview(pageDotView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {() -> Void in
            self.alpha = 1.0
        }, completion: {(_ finished: Bool) -> Void in
        })
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {() -> Void in
            self.alpha = 0.3
        }, completion: {(_ finished: Bool) -> Void in
            self.removeFromSuperview()
        })
    }
    
    // MARK: - ScrollViewDelegate
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if targetContentOffset.pointee.x.truncatingRemainder(dividingBy: screenWidth) == 0 {
            let index: Int = Int(floor(targetContentOffset.pointee.x / bounds.size.width))
            for i in 0..<dotImageView.count {
                if i == index {
                    dotImageView[i].image = UIImage(named: "icon_steps_scissor_active")
                } else {
                    dotImageView[i].image = UIImage(named: "icon_steps_scissor_normal")
                }
            }
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let index: Int = Int(floor(scrollView.contentOffset.x / bounds.size.width))
//        pageControl!.currentPage = index
//        pageControl?.setCurrentPage(index)
//    }

    //MARK: IntroductionViewDelegate
    func experienceButtonPress() {
        hide()
    }
}
