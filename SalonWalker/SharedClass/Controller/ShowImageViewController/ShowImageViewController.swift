//
//  ShowImageViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/29.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Kingfisher

class ShowImageViewController: BaseViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var naviTitleLabel: UILabel!
    
    private var photoImgUrlArray = [String]()
    private var currentIndex = 0
    private var naviTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addDismissGestureRecognizer()
        naviTitleLabel.text = naviTitle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToCurrentIndex()
    }
    
    func setupVCWith(photoImgUrl: [String], index: Int, naviTitle: String?) {
        self.photoImgUrlArray = photoImgUrl
        self.currentIndex = index
        self.naviTitle = naviTitle
    }
    
    private func scrollToCurrentIndex() {
        if currentIndex != -1, photoImgUrlArray.count > 0 {
            self.collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: [.centeredVertically, .centeredHorizontally], animated: false)
            self.currentIndex = -1
        }
    }
    
    @IBAction private func dismissButtonPress(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ShowImageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoImgUrlArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PortfolioCollectionCell.self), for: indexPath) as! PortfolioCollectionCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if photoImgUrlArray.count > 0, indexPath.item < photoImgUrlArray.count {
            (cell as! PortfolioCollectionCell).setupCellWith(photoUrl: photoImgUrlArray[indexPath.row], scaleEnable: true)
        }
    }
}

extension ShowImageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

extension ShowImageViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap{
            URL(string: photoImgUrlArray[$0.item])
        }
        ImagePrefetcher(urls: urls).start()
    }
}
