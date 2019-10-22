//
//  PhotoTool.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/1.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol PhotoToolDelegate : class {
    func didGetImage(_ image: UIImage)
    func didChooseDelete()
    func didCancel()
}

extension PhotoToolDelegate {
    func didChooseDelete() {}
    func didCancel() {}
}

class PhotoTool: NSObject {
    private static let sharedInstance = PhotoTool()
    
    private weak var delegate: PhotoToolDelegate?
    private var pickerViewShouldCrop = false
    private var cropRatio = CGSize.zero
    
    static func getImage(withDelegate delegate: PhotoToolDelegate?, crop: Bool, cropRatio:CGSize) {
        PhotoTool.getImageWith(delegate: delegate, crop: crop, cropRatio: cropRatio, deleteOption: false)
    }
    
    static func getImageWith(delegate: PhotoToolDelegate?) {
        PhotoTool.getImageWith(delegate: delegate, crop: false, cropRatio: CGSize.zero, deleteOption: false)
    }
    
    static func getImageWith(delegate: PhotoToolDelegate?, crop: Bool, cropRatio: CGSize, deleteOption: Bool) {
        PhotoTool.sharedInstance.delegate = delegate
        PhotoTool.sharedInstance.pickerViewShouldCrop = crop
        PhotoTool.sharedInstance.cropRatio = cropRatio
        
        let alert = UIAlertController(title: "選擇", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "拍照", style: .default) { (action: UIAlertAction) in
                DispatchQueue.main.async {
                    PhotoTool.setupPickerWithSourceType(.camera)
                }
            }
            alert.addAction(cameraButton)
        }
        
        let albumButton = UIAlertAction(title: "從相簿選擇", style: .default) { (action: UIAlertAction) in
            DispatchQueue.main.async {
                PhotoTool.setupPickerWithSourceType(.savedPhotosAlbum)
            }
        }
        alert.addAction(albumButton)
        
        if deleteOption {
            let deleteButton = UIAlertAction(title: "刪除", style: .destructive) { (action: UIAlertAction) in
                PhotoTool.sharedInstance.delegate?.didChooseDelete()
            }
            alert.addAction(deleteButton)
        }
        
        let cancelButton = UIAlertAction(title: "取消", style: .cancel) { (action: UIAlertAction) in
            DispatchQueue.main.async {
                PhotoTool.sharedInstance.delegate?.didCancel()
            }
        }
        alert.addAction(cancelButton)
        
        SystemManager.topViewController().present(alert, animated: true, completion: nil)
    }
    
    private static func setupPickerWithSourceType(_ sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = PhotoTool.sharedInstance
        
        PhotoTool.obtainPermission(forMediaSourceType: sourceType, success: {
            SystemManager.topViewController().present(picker, animated: true, completion: nil)
        }, failure: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                let title = (sourceType == .camera) ? "請至設定開啟相機權限" : "請至設定開啟相簿權限"
                SystemManager.showTwoButtonAlertWith(alertTitle:title , alertMessage: nil, leftButtonTitle: "取消", rightButtonTitle: "前往設定", leftHandler: nil, rightHandler: {
                    guard let url = URL(string: "\(UIApplication.openSettingsURLString)\(Bundle.main.bundleIdentifier ?? "")") else { return }
                    UIApplication.shared.openURL(url)
                })
            })
        })
    }
    
    private static func obtainPermission(forMediaSourceType sourceType: UIImagePickerController.SourceType, success: (()->Void)?, failure: (()->Void)?) {
        switch sourceType {
        case .photoLibrary, .savedPhotosAlbum:
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async { success?() }
                    break
                default:
                    DispatchQueue.main.async { failure?() }
                    break
                }
            }
            break
        case .camera:
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                DispatchQueue.main.async { success?() }
                break
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                    DispatchQueue.main.async {
                        if granted {
                            success?()
                        } else {
                            failure?()
                        }
                    }
                })
                break
            default:
                DispatchQueue.main.async { failure?() }
                break
            }
            break
        }
    }
}

extension PhotoTool: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        let mediaType = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)] as? String
        if mediaType == "public.image" {
            SystemManager.showLoading()
            DispatchQueue.global().async {
                guard let originImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
                    picker.dismiss(animated: true, completion: nil)
                    return
                }
                if picker.sourceType == .camera {
                    UIImageWriteToSavedPhotosAlbum(originImage, nil, nil, nil)
                }
                
                var scaleImage = originImage
                debugPrint("originalImage size:\(originImage.imageSize())")
                if scaleImage.size.width > 1024 {
                    scaleImage = scaleImage.compressForWidth(1024)
                    debugPrint("scaleImage size:\(scaleImage.imageSize())")
                }
                
                guard let data = scaleImage.jpegData(compressionQuality: 0.5), let image = UIImage(data: data) else {
                    picker.dismiss(animated: true, completion: nil)
                    return
                }
                debugPrint("scaleImage size:\(scaleImage.imageSize())")
                
                DispatchQueue.main.async {
                    SystemManager.hideLoading()
                    picker.dismiss(animated: true, completion: {
                        if PhotoTool.sharedInstance.pickerViewShouldCrop {
                            SystemManager.showAlertWith(alertTitle: "Not yet implement crop feature", alertMessage: nil, buttonTitle: "OK", handler: nil)
                        } else {
                            self.delegate?.didGetImage(image)
                        }
                    })
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        delegate?.didCancel()
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
