//
//  TopMenuView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/23.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol TopMenuViewDelegate: class {
    func didSelectedAt(_ index: Int)
}

class TopMenuView: IBInspectableView {

    private weak var delegate: TopMenuViewDelegate?
    
    private var collectionView: UICollectionView?
    private var topBorder: UIView?
    private var bottomBorder: UIView?
    
    private var itemWidth: CGFloat {
        get {
            return self.frame.size.width / CGFloat(titles.count)
        }
    }
    
    private var titles: [String] = []
    private var titleColor: UIColor?
    private var titleSelectedColor: UIColor?
    private var titleFont: UIFont?
    private var titleSelectedFont: UIFont?
    
    private var sliderView: UIView?
    private var sliderHeight: CGFloat = 3.0
    
    private var sliderY: CGFloat {
        get {
            return self.frame.size.height - sliderHeight
        }
    }
    
    private var sliderColor: UIColor?
    
    var selectedPageIndex: Int = 0 {
        didSet {
            if self.titles.count != 0 {
                collectionView?.reloadData()
                
                UIView.animate(withDuration: 0.3) {
                    self.sliderView?.frame = CGRect(x: self.itemWidth * CGFloat(self.selectedPageIndex), y: self.sliderY, width: self.itemWidth, height: self.sliderHeight)
                }
            }
        }
    }
    
    func setupViewWith(titles: [String], sliderColor: UIColor?, titleColor: UIColor?, titleSelectedColor: UIColor?, titleFont: UIFont?, titleSelectedFont: UIFont?, selectPageIndex: Int, delegate: TopMenuViewDelegate?, showBorder: Bool = false) {
        self.backgroundColor = UIColor.white
        
        self.delegate = delegate
        self.titles = titles
        self.sliderColor = sliderColor
        self.titleColor = titleColor
        self.titleSelectedColor = titleSelectedColor
        self.titleFont = titleFont
        self.titleSelectedFont = titleSelectedFont
        self.selectedPageIndex = selectPageIndex
        
        self.setupView()
        
        if showBorder {
            self.addBorder()
        }
    }
    
    private func setupView() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.register(UINib(nibName: "TopMenuViewBaseCell", bundle: nil), forCellWithReuseIdentifier: "TopMenuViewBaseCell")
        self.addSubview(collectionView!)
        
        sliderView = UIView(frame: CGRect(x: itemWidth * CGFloat(selectedPageIndex), y: sliderY, width: itemWidth , height: sliderHeight))
        sliderView?.backgroundColor = sliderColor
        self.collectionView?.addSubview(sliderView!)
    }
    
    private func addBorder() {
        var topBorderFrame = self.bounds
        topBorderFrame.size.height = 1
        var bottomBorderFrame = self.bounds
        bottomBorderFrame.origin.y = self.bounds.size.height - 1
        bottomBorderFrame.size.height = 1
        
        topBorder = UIView(frame: topBorderFrame)
        topBorder?.backgroundColor = color_EEEEEE
        bottomBorder = UIView(frame: bottomBorderFrame)
        bottomBorder?.backgroundColor = color_EEEEEE
        
        if let topBorder = topBorder, let bottomBorder = bottomBorder {
            self.addSubview(topBorder)
            self.addSubview(bottomBorder)
        }
    }
    
    func resizeFrame() {
        self.collectionView?.frame = self.bounds
        self.collectionView?.collectionViewLayout.invalidateLayout()
        self.sliderView?.frame = CGRect(x: self.itemWidth * CGFloat(self.selectedPageIndex), y: self.sliderY, width: self.itemWidth, height: self.sliderHeight)
        
        var topBorderFrame = self.bounds
        topBorderFrame.size.height = 1
        var bottomBorderFrame = self.bounds
        bottomBorderFrame.origin.y = self.bounds.size.height - 1
        bottomBorderFrame.size.height = 1
        self.topBorder?.frame = topBorderFrame
        self.bottomBorder?.frame = bottomBorderFrame
    }
    
}

extension TopMenuView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index: Int = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopMenuViewBaseCell", for: indexPath) as! TopMenuViewBaseCell
        cell.titleLabel?.text = titles.count > index ? titles[index] : ""
        
        if index == selectedPageIndex {
            cell.titleLabel?.font = titleSelectedFont
            cell.titleLabel?.textColor = titleSelectedColor
            cell.isSelected = true
        } else {
            cell.titleLabel?.font = titleFont
            cell.titleLabel?.textColor = titleColor
            cell.isSelected = false
        }
        return cell
    }
}

extension TopMenuView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.selectedPageIndex = indexPath.row
        delegate?.didSelectedAt(indexPath.row)
    }
}

extension TopMenuView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: self.frame.size.height - sliderHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
