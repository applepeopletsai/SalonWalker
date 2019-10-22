//
//  MultipleScrollBaseViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/18.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class MultipleScrollBaseViewController: UIViewController {

    weak var multipleScrollViewProtocol: MultipleScrollViewProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MultipleScrollBaseViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        multipleScrollViewProtocol?.baseScrollViewDidScroll(scrollView, offsetY: scrollView.contentOffset.y)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        multipleScrollViewProtocol?.baseScrollViewWillBeginDragging(scrollView, offsetY: scrollView.contentOffset.y)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        multipleScrollViewProtocol?.baseScrollViewWillBeginDecelerating(scrollView, offsetY: scrollView.contentOffset.y)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        multipleScrollViewProtocol?.baseScrollViewDidEndDragging(scrollView, offsetY: scrollView.contentOffset.y)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        multipleScrollViewProtocol?.baseScrollViewDidEndDecelerating(scrollView, offsetY: scrollView.contentOffset.y)
    }
}
