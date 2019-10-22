//
//  TabBarItemView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/21.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

struct MainTabBarItemModel {
    var selectImage: String
    var unSelectImage: String
}

protocol MainTabBarItemDelegate: class {
    func tabBarItemPressWithTag(_ tag: Int)
}

class MainTabBarItem: UIView {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var badgeLabel: UILabel!
    
    private weak var delegate: MainTabBarItemDelegate?
    
    var select: Bool = false {
        didSet {
            self.imageView.isHighlighted = select
        }
    }
    
    var badge: String? = nil {
        didSet {
            setupBadgeLabel()
        }
    }
    
    static func initWith(frame: CGRect, selectImage: String, unSelectImage: String, tag: Int, backgroundColor: UIColor, delegate: MainTabBarItemDelegate?) -> MainTabBarItem? {
        
        guard let tabBarItem = Bundle.main.loadNibNamed(String(describing: MainTabBarItem.self), owner: nil, options: nil)?.first as? MainTabBarItem else {
            return nil
        }
        
        tabBarItem.frame = frame
        tabBarItem.tag = tag
        tabBarItem.backgroundColor = backgroundColor
        tabBarItem.imageView.image = UIImage(named: unSelectImage)
        tabBarItem.imageView.highlightedImage = UIImage(named: selectImage)
        tabBarItem.delegate = delegate
        tabBarItem.select = (tag == 0) ? true : false
        tabBarItem.setupBadgeLabel()
        
        return tabBarItem
    }
    
    private func setupBadgeLabel() {
        self.badgeLabel.text = self.badge
        
        let transform: CGAffineTransform = (self.badge == nil) ? CGAffineTransform(scaleX: 0.01, y: 0.01) : .identity
        let alpha: CGFloat = (self.badge == nil) ? 0 : 1
        
        UIView.animate(withDuration: 0.3, animations: {
            self.badgeLabel.transform = transform
            self.badgeLabel.alpha = alpha
        })
    }
    
    @IBAction private func buttonPress(_ sender: UIButton) {
        self.delegate?.tabBarItemPressWithTag(self.tag)
    }

}
