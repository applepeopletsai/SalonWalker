//
//  CustomCameraExtension.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import MobileCoreServices
import DKImagePickerController

class CustomCameraExtension: DKImageBaseExtension, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var didCancel: (() -> Void)?
    var didFinishCapturingImage: ((_ image: UIImage, _ metadata: [AnyHashable : Any]?) -> Void)?
    var didFinishCapturingVideo: ((_ videoURL: URL) -> Void)?
    
    override func perform(with extraInfo: [AnyHashable : Any]) {
        guard let didFinishCapturingImage = extraInfo["didFinishCapturingImage"] as? ((UIImage, [AnyHashable : Any]?) -> Void)
            , let didFinishCapturingVideo = extraInfo["didFinishCapturingVideo"] as? ((URL) -> Void)
            , let didCancel = extraInfo["didCancel"] as? (() -> Void) else { return }
        
        self.didFinishCapturingImage = didFinishCapturingImage
        self.didFinishCapturingVideo = didFinishCapturingVideo
        self.didCancel = didCancel
        
        let camera = UIImagePickerController()
        camera.delegate = self
        camera.sourceType = .camera
        camera.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        self.context.imagePickerController.present(camera)
    }
    
    override func finish() {
        self.context.imagePickerController.dismiss(animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let mediaType = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)] as! String
        
        if mediaType == kUTTypeImage as String {
            let metadata = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaMetadata)] as! [AnyHashable : Any]
            let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
            self.didFinishCapturingImage?(image, metadata)
        } else if mediaType == kUTTypeMovie as String {
            let videoURL = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as! URL
            self.didFinishCapturingVideo?(videoURL)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.didCancel?()
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
