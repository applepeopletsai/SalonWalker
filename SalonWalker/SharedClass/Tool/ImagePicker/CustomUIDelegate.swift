//
//  CustomUIDelegate.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import DKImagePickerController

class CustomUIDelegate: DKImagePickerControllerBaseUIDelegate {
    
    override open func createDoneButtonIfNeeded() -> UIButton {
        if self.doneButton == nil {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.setTitle(LocalizedString("Lang_GE_027"), for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitleColor(UIColor(white: 0.5, alpha: 0.5), for: .disabled)
            button.addTarget(self.imagePickerController, action: #selector(DKImagePickerController.done), for: .touchUpInside)
            self.doneButton = button
        }
        
        return self.doneButton!
    }
    
    func createCancelButtonIfNeeded(imagePickerController: DKImagePickerController) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.setImage(UIImage(named: "ic_close_17x17"), for: .normal)
        button.addTarget(self.imagePickerController, action: #selector(imagePickerController.dismiss as () -> Void), for: .touchUpInside)
        return button
    }
    
    override open func updateDoneButtonTitle(_ button: UIButton) {
        button.isEnabled = (self.imagePickerController.selectedAssets.count > 0) ? true : false
    }
    
    override open func imagePickerController(_ imagePickerController: DKImagePickerController,
                                             showsCancelButtonForVC vc: UIViewController) {
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.createCancelButtonIfNeeded(imagePickerController: imagePickerController))
    }
    
    override open func prepareLayout(_ imagePickerController: DKImagePickerController, vc: UIViewController) {
        self.imagePickerController = imagePickerController
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.createDoneButtonIfNeeded())
        vc.navigationItem.rightBarButtonItem?.isEnabled = (self.imagePickerController.selectedAssets.count > 0) ? true : false
        imagePickerController.navigationBar.barTintColor = UIColor.black
        imagePickerController.navigationBar.barStyle = .black
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    // 自定義背景顏色
    override open func imagePickerControllerCollectionViewBackgroundColor() -> UIColor {
        return UIColor.black
    }
    
    // 自定義camera cell
    override func imagePickerControllerCollectionCameraCell() -> DKAssetGroupDetailBaseCell.Type {
        return CustomCameraCell.self
    }
    
    // 自定義photo cell
    override func imagePickerControllerCollectionImageCell() -> DKAssetGroupDetailBaseCell.Type {
        return CustomImageCell.self
    }
    
    // 自定義video cell
    override func imagePickerControllerCollectionVideoCell() -> DKAssetGroupDetailBaseCell.Type {
        return CustomVideoCell.self
    }
}
