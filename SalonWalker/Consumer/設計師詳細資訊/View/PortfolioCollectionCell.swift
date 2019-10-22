//
//  PortfolioCollectionCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class PortfolioCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView?.minimumZoomScale = 1.0
        scrollView?.maximumZoomScale = 6.0
    }
    
    func setupCellWith(photoUrl: String, scaleEnable: Bool = false) {
        self.imageView.setImage(with: photoUrl)
        self.scrollView?.isScrollEnabled = scaleEnable
    }
    
}

extension PortfolioCollectionCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
