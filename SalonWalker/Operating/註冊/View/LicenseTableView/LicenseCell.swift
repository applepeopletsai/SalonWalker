//
//  LicenseCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/5.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Photos

protocol LicenseCellDelegate: class {
    func choosePhotoWith(row: Int, image: UIImage, localIdentifier: String)
    func didEnterLicenseNameWith(row: Int, name: String)
    func decreaseLicenseWithRow(_ row: Int)
}

class LicenseCell: UITableViewCell {

    @IBOutlet private var textField: UITextField!
    @IBOutlet private var photoImageView: UIImageView!
    
    private var row: Int?
    private var selectPhoto: MultipleAsset?
    private weak var delegate: LicenseCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWith(model:LicenseImg, row: Int, target: LicenseCellDelegate?) {
        self.delegate = target
        self.row = row
        self.textField.text = model.name

        self.selectPhoto = nil
        if let localIdentifier = model.imageLocalIdentifier, localIdentifier.count != 0 {
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
            if let asset = assets.firstObject {
                self.selectPhoto = MultipleAsset(originalAsset: asset)
            }
        }
        
        if let url = model.imgUrl, url.count > 0 {
            self.photoImageView.setImage(with: url)
        } else {
            self.photoImageView.image = UIImage(named: "btn_image")
        }
    }
    
    @IBAction func photoButtonPress(_ sender: UIButton) {
        let selectAssets = (self.selectPhoto == nil) ? [] : [self.selectPhoto!]
        PresentationTool.showImagePickerWith(selectAssets: selectAssets, maxSelectCount: 1, showVideo: false, target: self)
    }
    
    @IBAction func decreaseLicenseButtonPress(_ sender: UIButton) {
        if let row = row {
            self.delegate?.decreaseLicenseWithRow(row)
        }
    }
}

extension LicenseCell: MultipleSelectImageViewControllerDelegate {
    
    func didSelectAssets(_ assets: [MultipleAsset]) {
        
        if let asset = assets.first {
            asset.fetchOriginalImage(completeBlock: { [unowned self] (image, info) in
                
                if let image = image, let row = self.row  {
                    self.delegate?.choosePhotoWith(row: row, image: image, localIdentifier: asset.localIdentifier)
                }
            })
        }
    }
    
    func didCancel() {}
}

extension LicenseCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let totalString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if let totalString = totalString, let row = row {
            self.delegate?.didEnterLicenseNameWith(row: row, name: totalString)
        }
        return true
    }
}
