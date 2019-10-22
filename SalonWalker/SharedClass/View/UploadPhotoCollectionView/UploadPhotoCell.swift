//
//  UploadPhotoCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol UploadPhotoCellDelegate: class {
    func addButtonPress()
    func deleteImageWith(_ indexPath: IndexPath)
}

class UploadPhotoCell: UICollectionViewCell {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    
    private weak var delegate: UploadPhotoCellDelegate?
    private var indexPath: IndexPath?
    
    func setupCellWith(model: CoverImg, indexPath: IndexPath, target: UploadPhotoCellDelegate?) {
        self.indexPath = indexPath
        self.delegate = target
        
        self.indicatorView.startAnimating()
        self.imageView.image = nil
        self.addButton.isHidden = true
        self.deleteButton.isHidden = true
        
        if indexPath.item == 0 {
            if model.tempImgId == -99 { // "加"按鈕
                self.indicatorView.stopAnimating()
                self.addButton.isHidden = false
            } else if model.tempImgId != -1 { // call完API並取得tempImgId後
                self.indicatorView.stopAnimating()
                if let url = model.imgUrl {
                    self.imageView.setImage(with: url)
                }
                self.deleteButton.isHidden = false
            } else if model.coverImgId != nil { // 原本的照片(編輯模式)
                self.indicatorView.stopAnimating()
                if let url = model.imgUrl {
                    self.imageView.setImage(with: url)
                }
                self.deleteButton.isHidden = false
            }
        } else {
            if model.tempImgId == -1 {
                self.indicatorView.startAnimating()
            } else {
                if let url = model.imgUrl {
                    self.imageView.setImage(with: url)
                }
                self.deleteButton.isHidden = false
                self.indicatorView.stopAnimating()
            }
        }
    }
    
    @IBAction private func addButtonPress(_ sender: UIButton) {
        self.delegate?.addButtonPress()
    }
    
    @IBAction private func deleteButtonPress(_ sender: UIButton) {
        if let indexPath = indexPath {
            self.delegate?.deleteImageWith(indexPath)
        }
    }
}
