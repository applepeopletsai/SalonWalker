//
//  ShowWorksPhotoCell.swift
//  SalonWalker
//
//  Created by Cooper on 2018/8/16.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher

enum DisplayCabinetType {
    case Photo ,Album ,Video
}

enum EditModeStatus {
    case Normal
    case Editing
}

protocol ShowWorksPhotoCellDelegate: class {
    func addButtonPress()
}

class ShowWorksPhotoCell: UICollectionViewCell {
    @IBOutlet private weak var topImageView: UIImageView!
    @IBOutlet private weak var topImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topImageViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topImageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topImageViewRightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomImageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var markButton: UIButton!
    @IBOutlet private weak var checkedButton: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    
    private weak var delegate: ShowWorksPhotoCellDelegate?
    private var mode: EditModeStatus?
    private var type: DisplayCabinetType = .Photo
    
    override func awakeFromNib() {
        super.awakeFromNib()
        topImageView.cancelOperation()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        topImageView.cancelOperation()
    }
    
    // 設計師上傳作品集
    func setupCellWith(model: MediaModel, type: DisplayCabinetType, mode: EditModeStatus, indexPath: IndexPath, target: ShowWorksPhotoCellDelegate?) {
        
        self.mode = mode
        delegate = target
        
        descriptionLabel.text = ""
        markButton.isHidden = true
        markButton.setTitle("", for: .normal)
        markButton.setImage(nil, for: .normal)
        checkedButton.isHidden = true
        addButton.isHidden = true
        topImageView.isHidden = true
        topImageViewTopConstraint.constant = 0
        topImageViewLeftConstraint.constant = 0
        topImageViewBottomConstraint.constant = 0
        topImageViewRightConstraint.constant = 0
        bottomImageView.isHidden = true
        
        if indexPath.item == 0 {
            if model.tempImgId == -99 {
                addButton.isHidden = false
            }
        } else {
            addButton.isHidden = true
            topImageView.isHidden = false
            if mode == .Editing {
                checkedButton.isHidden = false
                checkedButton.isSelected = model.selected!
            }
            switch type {
            case .Photo:
                if let photoUrl = model.photoUrl {
                    topImageView.setImage(with: photoUrl)
                }
            case .Album:
                if let url = model.coverUrl {
                    topImageView.setImage(with: url)
                }
                descriptionLabel.text = model.name
                bottomImageView.isHidden = false
                topImageViewTopConstraint.constant = 10
                topImageViewLeftConstraint.constant = 2
                topImageViewBottomConstraint.constant = -2
                topImageViewRightConstraint.constant = -10
                markButton.setImage(UIImage(named: "ic_album"), for: .normal)
                markButton.isHidden = false
            case .Video:
                if let videoUrl = model.videoUrl {
                    self.topImageView.getVideoImage(with: videoUrl, completion: { [weak self] (image,time,url) in
                        self?.topImageView.image = image
                        self?.markButton.isHidden = false
                        self?.markButton.setTitle(time, for: .normal)
                    })
                }
            }
        }
    }
    
    // 消費者查看設計師作品集
    func setupCellWith(model: MediaModel, type: DisplayCabinetType) {
        self.type = type
        descriptionLabel.text = nil
        markButton.isHidden = true
        markButton.setTitle(nil, for: .normal)
        markButton.setImage(nil, for: .normal)
        checkedButton.isHidden = true
        addButton.isHidden = true
        bottomImageView.isHidden = true
        topImageViewTopConstraint.constant = 0
        topImageViewLeftConstraint.constant = 0
        topImageViewBottomConstraint.constant = 0
        topImageViewRightConstraint.constant = 0
        
        switch type {
        case .Photo:
            if let urlString = model.photoUrl {
                self.topImageView.setImage(with: urlString)
            }
            break
        case .Album:
            if let urlString = model.coverUrl {
                self.topImageView.setImage(with: urlString)
            }
            markButton.setImage(UIImage(named: "ic_album"), for: .normal)
            markButton.isHidden = false
            bottomImageView.isHidden = false
            topImageViewTopConstraint.constant = 10
            topImageViewLeftConstraint.constant = 2
            topImageViewBottomConstraint.constant = -2
            topImageViewRightConstraint.constant = -10
            break
        case .Video:
            if let videoUrl = model.videoUrl {
                self.topImageView.getVideoImage(with: videoUrl, completion: { [weak self] (image,time,url) in
                    self?.topImageView.image = image
                    self?.markButton.isHidden = false
                    self?.markButton.setTitle(time, for: .normal)
                })
            }
            break
        }
    }
    
    func didEndDisplaying() {
        self.topImageView.kf.cancelDownloadTask()
        self.topImageView.cancelOperation()
    }
    
    func changeButtonHiddenStatus(_ input: Bool) {
        checkedButton.isHidden = input
    }
    
    func resetCheckedButtonSelectStatus() {
        checkedButton.isSelected = false
    }

    @IBAction private func addButtonPress(_ sender: UIButton) {
        delegate?.addButtonPress()
    }
    
}
