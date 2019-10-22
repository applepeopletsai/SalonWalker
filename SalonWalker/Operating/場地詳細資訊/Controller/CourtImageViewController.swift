//
//  CollectionViewController.swift
//  TabBar_practice
//
//  Created by Skywind on 2018/3/6.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class CourtImageViewController: MultipleScrollBaseViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var providerDetailModel: ProviderDetailModel? {
        didSet {
            if oldValue == nil {
                setupUI()
            }
        }
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.alwaysBounceVertical = true
    }
    
    // MARK: Method
    private func setupUI() {
        collectionView.reloadData()
    }
    
    // MARK: CollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return providerDetailModel?.works?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PortfolioCollectionCell", for: indexPath) as! PortfolioCollectionCell
        if let placeImgUrl = providerDetailModel?.works?[indexPath.item].placeImgUrl {
            cell.setupCellWith(photoUrl: placeImgUrl)
        }
        return cell
    }
    
    // MARK: CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (screenWidth - 3 * 2 ) / 3
        let cellHeight = cellWidth
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let photo = providerDetailModel?.works?.map({ $0.placeImgUrl ?? "" }) {
            let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: ShowImageViewController.self)) as! ShowImageViewController
            vc.setupVCWith(photoImgUrl: photo, index: indexPath.row, naviTitle: LocalizedString("Lang_HM_008"))
            self.present(vc, animated: true, completion: nil)
        }
    }
}

