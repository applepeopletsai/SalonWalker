//
//  ServiceItemCollectionView.swift
//  TestImagePicker
//
//  Created by Daniel on 2018/3/8.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

private let cellIdentifier = String(describing: ServiceItemCell.self)

class ServiceItemCollectionView: UIView {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var baseView: UIView?
    private var dataArray = [SvcCategoryModel]()
    
    /// 用於storyboard已經有ServiceItemCollectionView實體
    func setupCollectionViewWith(dataArray: [SvcCategoryModel]) {
        self.dataArray = dataArray
        self.collectionView.reloadData()
    }
    
    /// 用於創造ServiceItemCollectionView實體
    static func getCollectionViewWith(frame: CGRect, dataArray: [SvcCategoryModel]) -> ServiceItemCollectionView {
        return ServiceItemCollectionView.init(frame: frame, dataArray: dataArray)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCollectionView()
    }
    
    init(frame: CGRect, dataArray: [SvcCategoryModel]) {
        super.init(frame: frame)
        self.dataArray = dataArray
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        baseView = loadNib()
        baseView?.frame = self.bounds
        baseView?.backgroundColor = .white
        baseView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        addSubview(baseView!)
    }
    
    private func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}

extension ServiceItemCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ServiceItemCell
        let hidden = (indexPath.item == dataArray.count - 1)
        cell.setupCellWith(model: dataArray[indexPath.row], hidden: hidden)
        return cell
    }
}

extension ServiceItemCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100.0, height: self.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
}

