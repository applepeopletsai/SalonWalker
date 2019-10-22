//
//  MultipleScrollViewProtocol.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/18.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

//protocol MultipleScrollViewDelegate where Self: UIViewController {
//    var multipleScrollViewProtocol: MultipleScrollViewProtocol? { get set }
//}

protocol MultipleScrollViewProtocol: class {
    func baseScrollViewDidScroll(_ view: UIScrollView, offsetY: CGFloat)
    func baseScrollViewWillBeginDragging(_ view: UIScrollView, offsetY: CGFloat)
    func baseScrollViewWillBeginDecelerating(_ view: UIScrollView, offsetY: CGFloat)
    func baseScrollViewDidEndDecelerating(_ view: UIScrollView, offsetY: CGFloat)
    func baseScrollViewDidEndDragging(_ view: UIScrollView, offsetY: CGFloat)
}
