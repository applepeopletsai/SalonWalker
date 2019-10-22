//
//  CustomVideoCameraExtension.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/30.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import MobileCoreServices
import DKImagePickerController

class CustomVideoCameraExtension: DKImageBaseExtension, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var didCancel: (() -> Void)?
    var didFinishCapturingImage: ((_ image: UIImage, _ metadata: [AnyHashable : Any]?) -> Void)?
    var didFinishCapturingVideo: ((_ videoURL: URL) -> Void)?
    
    override func perform(with extraInfo: [AnyHashable : Any]) {
        guard let didFinishCapturingVideo = extraInfo["didFinishCapturingVideo"] as? ((URL) -> Void)
            , let didCancel = extraInfo["didCancel"] as? (() -> Void) else { return }
        
        self.didFinishCapturingVideo = didFinishCapturingVideo
        self.didCancel = didCancel
        
        let camera = UIImagePickerController()
        camera.delegate = self
        camera.sourceType = .camera
        camera.mediaTypes = [kUTTypeMovie as String]
        
        self.context.imagePickerController.present(camera)
    }
    
    override func finish() {
        self.context.imagePickerController.dismiss(animated: true)
    }
    
    // MARK: UIImagePickerControllerDelegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let videoURL = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as! URL
        self.didFinishCapturingVideo?(videoURL)
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
