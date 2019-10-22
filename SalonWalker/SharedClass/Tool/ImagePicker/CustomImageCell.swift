//
//  CustomImageCell.swift
//  DKImagePickerController
//
//  Created by Daniel on 2018/3/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import DKImagePickerController

class CustomImageCell: DKAssetGroupDetailBaseCell {
    
    private var selectImageView: UIImageView!
    
    class override func cellReuseIdentifier() -> String {
        return "CustomImageCell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        
        self.thumbnailImageView.frame = self.bounds
        self.thumbnailImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.addSubview(self._thumbnailImageView)
        
        self.selectImageView = UIImageView(frame: CGRect(x: self.bounds.size.width - 25, y: 8, width: 20, height: 20))
        self.selectImageView.contentMode = .scaleAspectFill
        self.selectImageView.clipsToBounds = true
        self.selectImageView.backgroundColor = .clear
        self.contentView.addSubview(self.selectImageView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var thumbnailImage: UIImage? {
        didSet {
            self.thumbnailImageView.image = self.thumbnailImage
        }
    }
    
    override var thumbnailImageView: UIImageView {
        get {
            return _thumbnailImageView
        }
    }
    
    internal lazy var _thumbnailImageView: UIImageView = {
        let thumbnailImageView = UIImageView()
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true

        return thumbnailImageView
    }()
    
    override var isSelected: Bool {
        didSet {
            self.selectImageView.image = (super.isSelected) ? UIImage(named: "checkbox_checked_20x20") : UIImage(named: "checkbok_upload")
        }
    }
}
