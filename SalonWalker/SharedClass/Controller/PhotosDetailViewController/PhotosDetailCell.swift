//
//  PhotosDetailCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/13.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import AVFoundation
import DKPhotoGallery

class PhotosDetailCell: UICollectionViewCell {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var videoView: DKPlayerView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        videoView.closeBlock = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
        photoImageView.kf.cancelDownloadTask()
        videoView.asset = nil
    }
    
    func setupCellWith(model: PhotoDetailModel, type: DisplayCabinetType) {
        if type == .Video  {
            let asset = AVAsset(url: URL(string: model.url)!)
            videoView.isHidden = false
            photoImageView.isHidden = true
            videoView.asset = asset
        } else {
            videoView.isHidden = true
            photoImageView.isHidden = false
            photoImageView.setImage(with: model.url)
        }
        self.descriptionLabel.text = model.des
    }
}

extension PhotosDetailCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
}
