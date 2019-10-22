//
//  ProviderInfoCollectionView.swift
//  SalonWalker
//
//  Created by Skywind on 2018/6/21.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

@objc protocol ProviderInfoCollectionViewDelegate: class {
    func didSelectItemAt(indexPath: IndexPath)
    func heartButtonClickAt(indexPath: IndexPath)
    func collectionWillDisplayCellAt(indexPath: IndexPath)
    @objc optional func findSiteButtonPress()
}

class ProviderInfoCollectionView: UICollectionView {

    @IBInspectable private var showNoFavCell: Bool = false
    
    private var providerListArray: [ProviderListModel]?
    private var designerListArray: [DesignerListModel]?
    private weak var providerInfoCollectionViewDelegate: ProviderInfoCollectionViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.dataSource = self
        self.alwaysBounceVertical = true
        registerCell()
    }

    private func registerCell() {
        self.register(UINib(nibName: "ProviderInfoCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ProviderInfoCollectionCell")
        if showNoFavCell {
            self.register(UINib(nibName: "ProviderInfoCollectionCell_NoFav", bundle: nil), forCellWithReuseIdentifier: "ProviderInfoCollectionCell_NoFav")
        }
    }
    
    func setupCollectionViewWith(providerListArray: [ProviderListModel]?, designerListArray: [DesignerListModel]?, target: ProviderInfoCollectionViewDelegate) {
        self.providerListArray = providerListArray
        self.designerListArray = designerListArray
        self.providerInfoCollectionViewDelegate = target
    }
    
    func reloadData(providerListArray: [ProviderListModel]?, designerListArray: [DesignerListModel]?, reloadTableView: Bool = true) {
        self.providerListArray = providerListArray
        self.designerListArray = designerListArray
        if reloadTableView {
            self.reloadData()
        }
    }
}

extension ProviderInfoCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if showNoFavCell && (providerListArray?.count ?? 0) == 0 && (designerListArray?.count ?? 0) == 0 {
            return 1
        }
        return providerListArray?.count ?? designerListArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if showNoFavCell && (providerListArray?.count ?? 0) == 0 && (designerListArray?.count ?? 0) == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProviderInfoCollectionCell_NoFav", for: indexPath) as! ProviderInfoCollectionCell_NoFav
            cell.delegate = self
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProviderInfoCollectionCell", for: indexPath) as! ProviderInfoCollectionCell
        cell.setupCellWith(indexPath: indexPath, providerModel: providerListArray?[indexPath.row], designerModel: designerListArray?[indexPath.row], delegate: self)
        return cell
    }
}

extension ProviderInfoCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (providerListArray?.count ?? 0) != 0 || (designerListArray?.count ?? 0) != 0 {
            providerInfoCollectionViewDelegate?.didSelectItemAt(indexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if showNoFavCell && (providerListArray?.count ?? 0) == 0 && (designerListArray?.count ?? 0) == 0 {
            return UIEdgeInsets.zero
        }
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if showNoFavCell && (providerListArray?.count ?? 0) == 0 && (designerListArray?.count ?? 0) == 0 {
            return 0
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if showNoFavCell && (providerListArray?.count ?? 0) == 0 && (designerListArray?.count ?? 0) == 0 {
            return 0
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if showNoFavCell && (providerListArray?.count ?? 0) == 0 && (designerListArray?.count ?? 0) == 0 {
            return CGSize(width: screenWidth, height: screenHeight - 44 - 49 - UIApplication.shared.statusBarFrame.size.height)
        }
        
        let cellWidth = (screenWidth - (15 * 2) - 10) / 2
        let value: CGFloat = (UserManager.sharedInstance.userIdentity == .store) ? 256 : 270
        let cellHeight = cellWidth / 170 * value
        //原 invision 比例: Width: 170  height:256 , PM 要求價格Label要 ２行 , 微調至 270 , By Scott 2018/06/21
//        var height: CGFloat = 270
//        if SizeTool.isIphone5() {
//            height = 285
//        }
//        if SizeTool.isIphone6Plus() {
//            height = 260
//        }
//        let cellHeight = cellWidth * height / 170
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is ProviderInfoCollectionCell {
            self.providerInfoCollectionViewDelegate?.collectionWillDisplayCellAt(indexPath: indexPath)
        }
    }
}

extension ProviderInfoCollectionView: ProviderInfoCollectionCellDelegate {
    func heartButtonClickAt(_ indexPath: IndexPath) {
        self.providerInfoCollectionViewDelegate?.heartButtonClickAt(indexPath: indexPath)
    }
}

extension ProviderInfoCollectionView: ProviderInfoCollectionCell_NoFavDelegate {
    func findSiteButtonPress() {
        self.providerInfoCollectionViewDelegate?.findSiteButtonPress?()
    }
}

