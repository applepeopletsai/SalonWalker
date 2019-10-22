//
//  CustomVideoCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/23.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import DKImagePickerController

class CustomVideoCell: DKAssetGroupDetailBaseCell {
    
    private var selectImageView: UIImageView!
    private var durationLabel: UILabel!
    
    class override func cellReuseIdentifier() -> String {
        return "CustomVideoCell"
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
        
        self.durationLabel = UILabel(frame: CGRect(x: 0, y: self.bounds.size.height - 20, width: self.bounds.width - 5, height: 20))
        self.durationLabel.textAlignment = .right
        self.durationLabel.font = UIFont.systemFont(ofSize: 12)
        self.durationLabel.textColor = UIColor.white
        self.durationLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.addSubview(self.durationLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override weak var asset: DKAsset? {
        didSet {
            if let asset = asset {
                let minutes: Int = Int(asset.duration) / 60
                let seconds: Int = Int(round(asset.duration)) % 60
                self.durationLabel.text = String(format: "\(minutes):%02d", seconds)
            }
        }
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
