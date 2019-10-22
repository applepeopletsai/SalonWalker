//
//  ScrollPageMenuControl.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol ScrollPageMenuControlDelegate: class {
    func didSelectetPageAt(_ pageIndex: Int)
}

class ScrollPageMenuControl: NSObject {

    private weak var scrollView: UIScrollView?
    private weak var topView: TopMenuView?
    private weak var delegate: ScrollPageMenuControlDelegate?
    private var hasAlreadyResize = false
    
    private var currentPage: Int = 0
    private var lastPage: Int = 0
    
    private var titles : [String] = []
    private var sliderColor: UIColor?
    
    private var childVCs: [UIViewController] = [] {
        didSet {
            let count: Int = childVCs.count
            scrollView?.contentSize = CGSize(width: scrollView!.frame.size.width * CGFloat(count), height: 0)
            for i in 0..<count {
                let vc = childVCs[i]
                vc.view.frame = CGRect(x: scrollView!.frame.size.width * CGFloat(i), y: 0, width: scrollView!.frame.size.width, height: scrollView!.frame.size.height)
                vc.view.layoutIfNeeded()
                scrollView?.addSubview(vc.view)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupPageViewWith(topView: TopMenuView, scrollView: UIScrollView, titles: [String], childVCs: [UIViewController], baseVC: UIViewController, delegate: ScrollPageMenuControlDelegate?, sliderColor: UIColor? = color_2F10A0, titleColor: UIColor? = .black, titleSelectedColor: UIColor? = color_2F10A0, titleFont: UIFont? = UIFont.systemFont(ofSize: 14), titleSelectedFont: UIFont? = UIFont.systemFont(ofSize: 14), selectPageIndex: Int = 0, showBorder: Bool = false) {
        
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.delaysContentTouches = false
        
        baseVC.view.layoutIfNeeded()
        
        self.topView = topView
        self.scrollView = scrollView
        self.childVCs = childVCs
        self.titles = titles
        self.delegate = delegate
        
        self.topView?.setupViewWith(titles: titles, sliderColor: sliderColor, titleColor: titleColor, titleSelectedColor: titleSelectedColor, titleFont: titleFont, titleSelectedFont: titleSelectedFont, selectPageIndex: selectPageIndex, delegate: self, showBorder: showBorder)

        for vc: UIViewController in childVCs {
            baseVC.addChild(vc)
        }
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: UIDevice.current)
    }
    
    func changeCurrentPage(_ index: Int) {
        currentPage = index
        topView?.selectedPageIndex = index
        scrollToCurrentIndex()
    }
    
    func getCurrentPage() -> Int {
        return currentPage
    }
    
    func getLastPage() -> Int {
        return lastPage
    }
    
    /// call this function to resize scrollview contentsize and controller view size in ViewDidLayoutSubviews
    func resizeFrame() {
        
        if let scrollView = scrollView, !hasAlreadyResize {
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(childVCs.count), height: 0)
            for i in 0..<childVCs.count {
                let vc = childVCs[i]
                vc.view.frame = CGRect(x: scrollView.frame.size.width * CGFloat(i), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                vc.view.layoutIfNeeded()
            }
            topView?.resizeFrame()
            hasAlreadyResize = true
        }
    }
    
    @objc func orientationChanged(_ note: Notification?) {
        // 重設UI frame
        
        let point = CGPoint(x: scrollView!.frame.size.width * CGFloat(topView!.selectedPageIndex), y: 0)
        scrollView!.setContentOffset(point, animated: false)
        topView?.resizeFrame()
        
        for i in 0..<childVCs.count {
            let vc: UIViewController? = childVCs[i]
            vc?.view.frame = CGRect(x: scrollView!.frame.size.width * CGFloat(i), y: 0, width: scrollView!.frame.size.width, height: scrollView!.frame.size.height)
            vc?.view.layoutIfNeeded()
        }
        
        scrollView?.contentSize.width = scrollView!.frame.size.width * CGFloat(titles.count)
    }
    
    private func scrollToCurrentIndex() {
        let width = scrollView!.frame.size.width * CGFloat(currentPage)
        let point = CGPoint(x: width, y: 0)
        scrollView?.setContentOffset(point, animated: true)
    }
}

extension ScrollPageMenuControl: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        lastPage = currentPage
        currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        delegate?.didSelectetPageAt(currentPage)
    }
}

extension ScrollPageMenuControl: TopMenuViewDelegate {
    
    func didSelectedAt(_ index: Int) {
        lastPage = currentPage
        if currentPage != index {
            delegate?.didSelectetPageAt(index)
        }
    }
}

