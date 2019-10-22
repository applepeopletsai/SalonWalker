//
//  MultipleSelectImageViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Photos
import DKImagePickerController

protocol MultipleSelectImageViewControllerDelegate: class {
    func didSelectAssets(_ assets: [MultipleAsset])
    func didCancel()
}

class MultipleSelectImageViewController: DKImagePickerController {
    
    override func canSelect(asset: DKAsset, showAlert: Bool) -> Bool {
        if self.maxSelectableCount == 1 {
            super.deselectAll()
        }
        
        if self.maxSelectableCount > 0 {
            let shouldSelect = self.selectedAssetIdentifiers.count < self.maxSelectableCount
            return shouldSelect
        }
        
        if asset.type == .video {
            for asseta in selectedAssets {
                if asseta.type == .video {
                    return false
                }
            }
        }
        return true
    }
}

class MultipleAsset: DKAsset {
    
    override init(originalAsset: PHAsset) {
        super.init(originalAsset: originalAsset)
    }
    
    override init(image: UIImage) {
        super.init(image: image)
    }
    
    static func transfer(_ assets: [DKAsset]) -> [MultipleAsset] {
        var array: [MultipleAsset] = []
        for asset in assets {
            if let originalAsset = asset.originalAsset {
                array.append(MultipleAsset(originalAsset: originalAsset))
            }
        }
        return array
    }
}

