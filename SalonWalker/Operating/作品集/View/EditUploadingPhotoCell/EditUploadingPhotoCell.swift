//
//  EditUploadingPhotoCell.swift
//  SalonWalker
//
//  Created by Cooper on 2018/8/24.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Photos
import IQKeyboardManagerSwift

protocol EditUploadingPhotoCellDelegate: class {
    func addUploadingPhotoComment(comment: String, indexPath: IndexPath)
    func deleteUploadingPhoto(indexPath: IndexPath)
}

class EditUploadingPhotoCell: UITableViewCell {

    @IBOutlet private weak var mainImage: UIImageView!
    @IBOutlet weak var noteView: IBInspectableTextView!
    @IBOutlet private weak var deleteButton: UIButton!
    
    private var indexPath: IndexPath?
    private weak var delegate: EditUploadingPhotoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        noteView.text = ""
    }
    
    func setupEditingWith(model: MediaModel, indexPath: IndexPath, delegate: EditUploadingPhotoCellDelegate) {
        self.noteView.text = model.photoDesc ?? ""
        self.indexPath = indexPath
        self.delegate = delegate
        if let localIdentifier = model.imageLocalIdentifier, localIdentifier.count != 0 {
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
            if let asset = assets.firstObject {
                MultipleAsset(originalAsset: asset).fetchOriginalImage { (image, info) in
                    if let image = image {
                        self.mainImage.image = image
                    }
                }
            }
        }

        if let imageUrl = model.photoUrl {
            self.mainImage.setImage(with: imageUrl)
        }
    }
    
    @IBAction func removeCurrentPhoto(_ sender: UIButton) {
        IQKeyboardManager.shared.resignFirstResponder()
        
        self.delegate?.deleteUploadingPhoto(indexPath: self.indexPath!)
    }
}

extension EditUploadingPhotoCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let inputString = (textView.text as NSString?)?.replacingCharacters(in: range, with: text).trimmingCharacters(in: .whitespaces)
        if let indexPath = indexPath, let inputString = inputString {
            self.delegate?.addUploadingPhotoComment(comment: inputString, indexPath: indexPath)
        }
        return true
    }
}
