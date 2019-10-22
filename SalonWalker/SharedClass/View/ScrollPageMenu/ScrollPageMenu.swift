//
//  ScrollPageMenu.swift
//  pageMenu
//
//  Created by skywind on 2018/3/7.
//  Copyright © 2018年 Jimmy. All rights reserved.
//

import UIKit
protocol ScrollPageMenuDelegate: class {
    func pageMenuDidSelect(at pageIndex: Int)
}

class ScrollPageMenu: UIView,UIScrollViewDelegate,TopViewDelegate {
    func topView(_ topView: TopView?, didSelectedBtnAt index: Int) {
        let width = scrollView!.frame.size.width * CGFloat(index)
        let point = CGPoint(x: width, y: 0)
        scrollView?.setContentOffset(point, animated: true)
        delegate?.pageMenuDidSelect(at: index)
    }
    
    weak var delegate: ScrollPageMenuDelegate?

    /** 子控制器數組 */
    var childViews = [UIViewController]() {
        didSet{
            let count: Int = childViews.count
            scrollView?.contentSize = CGSize(width: scrollView!.frame.size.width * CGFloat(count), height: 0)
            for i in 0..<count {
                let childVc = childViews[i]
                childVc.view.frame = CGRect(x: scrollView!.frame.size.width * CGFloat(i), y: 0, width: scrollView!.frame.size.width, height: scrollView!.frame.size.height)
                childVc.view.layoutIfNeeded()
                scrollView?.addSubview(childVc.view)
            }
        }
    }
    
    /** tab的標題 */
    var titles : [String] = []{
        didSet{
            topView?.titles = titles;
        }
    }
    
    /** 預設選中的頁面 */
    var selectedPageIndex: Int = 0 {
        didSet{
            topView?.selectedPageIndex = selectedPageIndex
        }
    }
    /** 每一行所顯示的按鈕個數 */
    var numberOfTitles: Int = 0
    
    // 滑塊
    /** 文字下面滑塊的顏色 */
    var sliderColor: UIColor? {
        didSet {
            topView?.sliderColor = sliderColor
            topView?.slider?.backgroundColor = sliderColor
        }
    }

    weak var topView: TopView?
    weak var scrollView: UIScrollView?
    var isLoad = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isLoad {
            isLoad = true
            scrollView?.isScrollEnabled = false
        }
    }

    // MARK: - setter
    func setupPageView(_ topView: TopView, scrollView: UIScrollView, titles: [String], childViews: [UIViewController], delegate: UIViewController,sliderColor:UIColor, titleColor:UIColor?, titleSelectedColor:UIColor?, titleFont:UIFont? = nil, titleSelectedFont:UIFont? = nil) {
        topView.delegate = self
        topView.tag = 1
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        self.topView = topView
        self.scrollView = scrollView
        self.childViews = childViews
        self.titles = titles
        
        topView.sliderColor = sliderColor
        topView.titleColor = titleColor
        topView.titleSelectedColor = titleSelectedColor
        topView.titleFont = titleFont
        topView.titleSelectedFont = titleSelectedFont
        topView.setupView()
        // 更改topView 顯示層級
        delegate.view.insertSubview(topView, aboveSubview: scrollView)
        for vc: UIViewController in childViews {
            delegate.addChildViewController(vc)
        }
        
        // 監聽螢幕翻轉事件
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: .UIDeviceOrientationDidChange, object: UIDevice.current)

    }
    
    // 畫面轉向UI處理
    
    @objc func orientationChanged(_ note: Notification?) {
        // 重設UI frame
        let point = CGPoint(x: scrollView!.frame.size.width * CGFloat(topView!.selectedPageIndex), y: 0)
        scrollView!.setContentOffset(point, animated: false)
        topView?.sliderWidth = scrollView!.frame.size.width/CGFloat(titles.count)

        for i in 0..<childViews.count {
            let vc: UIViewController? = childViews[i]
            vc?.view.frame = CGRect(x: scrollView!.frame.size.width * CGFloat(i), y: 0, width: scrollView!.frame.size.width, height: scrollView!.frame.size.height)
        }
        scrollView?.contentSize.width = scrollView!.frame.size.width * CGFloat(titles.count)
    }


    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.size.width / CGFloat(titles.count) * (scrollView.contentOffset.x / scrollView.frame.size.width)
        print(width)
        topView?.sliderLeading?.constant = width

    }
    
    // 滚动的时候上面的按钮跟着变换
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage: Int = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        topView?.selectedPageIndex = currentPage
    }
    


}
