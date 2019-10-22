//
//  TabBarView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/21.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol MainTabBarDelegate: class {
    func didSelectItemAt(_ index: Int)
}

class MainTabBar: UIView {

    var selectIndex: Int = 0 {
        didSet {
            changeSelectIndex()
        }
    }
    
    var tabBarItemArray: [MainTabBarItem] = []
    private weak var delegate: MainTabBarDelegate?
    
    static func initWith(frame: CGRect, tabBarItemModelArray:[MainTabBarItemModel], backgroundColor: UIColor, delegate: MainTabBarDelegate?) -> MainTabBar {
        let view = MainTabBar(frame: frame)
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -3)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 3
        view.delegate = delegate
        view.setupTabBarWith(tabBarItemModelArray: tabBarItemModelArray, backgroundColor: backgroundColor)
        return view
    }
    
    private func setupTabBarWith(tabBarItemModelArray:[MainTabBarItemModel], backgroundColor: UIColor) {
        for i in 0..<tabBarItemModelArray.count {
            let width = self.frame.size.width / CGFloat(tabBarItemModelArray.count)
            let height = self.frame.size.height
            let x = width * CGFloat(i)
            let frame = CGRect(x: x, y: 0, width: width, height: height)
            let model = tabBarItemModelArray[i]
            
            guard let tabBarItem = MainTabBarItem.initWith(frame: frame, selectImage: model.selectImage, unSelectImage: model.unSelectImage, tag: i, backgroundColor: backgroundColor, delegate: self) else {
                return
            }
            self.addSubview(tabBarItem)
            self.tabBarItemArray.append(tabBarItem)
        }
    }
    
    private func changeSelectIndex() {
        for item in tabBarItemArray {
            item.select = false
        }
        tabBarItemArray[selectIndex].select = true
//        self.delegate?.didSelectItemAt(self.selectIndex)
    }
}

extension MainTabBar: MainTabBarItemDelegate {
    
    func tabBarItemPressWithTag(_ tag: Int) {
//        self.selectIndex = tag
        self.delegate?.didSelectItemAt(tag)
    }
}

