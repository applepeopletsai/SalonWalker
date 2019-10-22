//
//  PortfolioCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol PortfolioCellDelegate: class {
    func watchMoreButtonPress(at index: Int)
}

class PortfolioCell: UITableViewCell {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private weak var delegate: PortfolioCellDelegate?
    private var photoArray: [WorksModel] = []
    private var row: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCellWith(title: String, photoArray: [WorksModel], row: Int, delegate: PortfolioCellDelegate?) {
        self.titleLabel.text = title
        self.photoArray = photoArray
        self.row = row
        self.delegate = delegate
        self.collectionView.reloadData()
    }
    
    @IBAction private func watchMoreButtonPress(_ sender: UIButton) {
        self.delegate?.watchMoreButtonPress(at: self.row)
    }
}

extension PortfolioCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PortfolioCollectionCell.self), for: indexPath) as! PortfolioCollectionCell
        if let worksImgUrl = photoArray[indexPath.item].worksImgUrl {
            cell.setupCellWith(photoUrl: worksImgUrl)
        } else if let customerImgUrl = photoArray[indexPath.item].customerImgUrl {
            cell.setupCellWith(photoUrl: customerImgUrl)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.bounds.size.height - 10 - 10 - 20 - 10 - 10
        return CGSize(width: width, height: width)
    }
    
}

