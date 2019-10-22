//
//  EditUploadVideoCell.swift
//  SalonWalker
//
//  Created by Cooper on 2018/9/10.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import DKPhotoGallery
import AVFoundation

protocol EditUploadingVideoCellDelegate: class {
    func addUploadingVideoComment(comment: String, indexPath: IndexPath)
    func deleteUploadingVideo(indexPath: IndexPath)
}

class EditUploadingVideoCell: UITableViewCell {

    @IBOutlet private weak var mainView: DKPlayerView!
    @IBOutlet private weak var noteTextView: IBInspectableTextView!
    @IBOutlet private weak var deleteButton: UIButton!
    
    private var indexPath: IndexPath?
    private weak var delegate: EditUploadingVideoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.closeBlock = nil
    }
    
    func setupEditingModelVideo(video: VideoDetailModel, indexPath: IndexPath, delegate: EditUploadingVideoCellDelegate) {
        self.indexPath = indexPath
        self.delegate = delegate
        mainView.asset = video.avURLAsset
        noteTextView.text = video.comment
    }

    @IBAction func removeCurrentVideo(_ sender: UIButton) {
        self.delegate?.deleteUploadingVideo(indexPath: self.indexPath!)
    }
}

extension EditUploadingVideoCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let totalString = (textView.text as NSString?)?.replacingCharacters(in: range, with: text).trimmingCharacters(in: .whitespaces)
        if let totalString = totalString, let indexPath = indexPath {
            self.delegate?.addUploadingVideoComment(comment: totalString, indexPath: indexPath)
        }
        return true
    }
}
