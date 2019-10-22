//
//  FashionTrendTableViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/3/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol FashionTrendTableViewCellDelegate: class {
    func didSelectItemWithIndex(_ index: Int)
    func watchMoreButtonPressWithIndex(_ index: Int)
}

class FashionTrendTableViewCell: UITableViewCell,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    // MARK: IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var moreButton: UIButton!
    @IBOutlet private weak var fashionTrendCollectionView: UICollectionView!
    
    // MARK: Property
    private var articleArray: [ArticleModel] = []
    weak var delegate : FashionTrendTableViewCellDelegate?
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Method
    func setupWithCell(dataArray: [ArticleModel], index: Int, delegate: FashionTrendTableViewCellDelegate?) {
        self.titleLabel.text = LocalizedString("Lang_HM_019")
        self.moreButton.tag = index
        self.delegate = delegate
        
        self.articleArray = dataArray
        self.fashionTrendCollectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FashionTrendCollectionViewCell", for: indexPath) as! FashionTrendCollectionViewCell
        cell.setupCellWith(model: articleArray[indexPath.row])
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.didSelectItemWithIndex(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemWitch = screenWidth / 375 * 200
        let itemHeight = collectionView.frame.size.height - 16
        return CGSize(width: itemWitch, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
    }
    
    // MARK: Event Handler
    @IBAction private func watchMoreButtonPress(_ sender: UIButton) {
        self.delegate?.watchMoreButtonPressWithIndex(sender.tag)
    }
}
