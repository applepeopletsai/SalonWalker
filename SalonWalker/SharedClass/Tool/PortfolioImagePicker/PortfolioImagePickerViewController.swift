//
//  PortfolioImagePickerViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/22.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import DKImagePickerController

enum UploadPortfolioType {
    case Photo, Album, Video
}

protocol PortfolioImagePickerViewControllerDelegate: class {
    func didSelectAssets(assets: [MultipleAsset], displayType: DisplayCabinetType, uploadPortfolioType: UploadPortfolioType)
    func didCancel()
}

class PortfolioImagePickerViewController: DKImagePickerController {

    var disPlayType: DisplayCabinetType = .Photo
    var uploadPortfolioType: UploadPortfolioType = .Photo
    
    override func done() {
        if disPlayType == .Video {
            self.uploadPortfolioType = .Video
            self.superDone()
        } else if disPlayType == .Album {
            self.uploadPortfolioType = .Album
            self.superDone()
        } else {
            let photoAction: actionClosure = { [unowned self] in
                self.uploadPortfolioType = .Photo
                self.superDone()
            }
            let albumAction: actionClosure = { [unowned self] in
                self.uploadPortfolioType = .Album
                self.superDone()
            }
            SystemManager.showAlertSheetWith(title: nil, message: nil, buttonTitles: [LocalizedString("Lang_PF_001"),LocalizedString("Lang_PF_002")], actions: [photoAction,albumAction])
        }
    }
    
    private func superDone() {
        super.done()
    }
    
}
