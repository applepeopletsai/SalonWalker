//
//  AlertTool.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/27.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import DKImagePickerController

typealias actionClosure = (() -> Void)

private enum AlertType {
    case NoButton, OneButton, TwoButton
}

class PresentationTool: NSObject {
    
    static func showNoButtonAlertWith(image: UIImage?, message: String, autoDismiss: Bool = true, completion: actionClosure?) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: NoButtonAlertViewController.self)) as! NoButtonAlertViewController
        vc.setupVCWith(image: image, message: message)
        AlertPresentationController(presentedViewController:vc, presenting: SystemManager.topViewController()).present(height: calculateHeightWith(text: message, multiplying: multiplying(.NoButton)), autoDismiss: autoDismiss, autoDismissCompletion: completion)
    }
    
    static func showOneButtonAlertWith(image: UIImage?, message: String, buttonTitle: String, buttonAction:actionClosure?) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: OneButtonAlertViewController.self)) as! OneButtonAlertViewController
        vc.setupVCWith(image: image, message: message, buttonTitle: buttonTitle, buttonAction: buttonAction)
        AlertPresentationController(presentedViewController:vc, presenting: SystemManager.topViewController()).present(height: calculateHeightWith(text: message, multiplying: multiplying(.OneButton)))
    }
    
    static func showTwoButtonAlertWith(image: UIImage?, message: String, leftButtonTitle: String, leftButtonAction:actionClosure?, rightButtonTitle: String, rightButtonAction:actionClosure?) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: TwoButtonAlertViewController.self)) as! TwoButtonAlertViewController
        vc.setupVCWith(image: image, message: message, leftButtonTitle: leftButtonTitle, leftButtonAction: leftButtonAction, rightButtonTitle: rightButtonTitle, rightButtonAction: rightButtonAction)
        AlertPresentationController(presentedViewController:vc, presenting: SystemManager.topViewController()).present(height: calculateHeightWith(text: message, multiplying: multiplying(.TwoButton)))
    }
    
    static func showReportAlert_OnlyReasonWith(leftButtonAction: actionClosure?, rightButtonAction: ((String) -> Void)?) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: TwoButtonTextViewAlertViewController.self)) as! TwoButtonTextViewAlertViewController
        vc.setupVCWith(image: UIImage(named: "img_pop_warning"), title: LocalizedString("Lang_DD_019"), leftButtonTitle: LocalizedString("Lang_GE_060"), leftButtonAction: leftButtonAction, rightButtonTitle: LocalizedString("Lang_RD_036"), rightButtonAction: rightButtonAction, textViewPlcaeHolderKey: "Lang_DD_020")
        AlertPresentationController(presentedViewController: vc, presenting: SystemManager.topViewController()).present(height: screenHeight * 0.65)
    }
    
    static func showReportAlert_HaveChooseReason(itemArray: [String], leftButtonAction: actionClosure?, rightButtonAction: ((String,Int) -> Void)?) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: TextViewPickerViewAlertViewController.self)) as! TextViewPickerViewAlertViewController
        vc.setupVCWith(image: UIImage(named: "img_pop_warning"), message: LocalizedString("Lang_RV_034"), itemHint: LocalizedString("Lang_RV_035"), itemArray: itemArray, textPlaceHolderKey: "Lang_RV_036", leftButtonTitle: LocalizedString("Lang_GE_060"), leftButtonAction: leftButtonAction, rightButtonTitle: LocalizedString("Lang_GE_024"), rightButtonAction: rightButtonAction)
        AlertPresentationController(presentedViewController: vc, presenting: SystemManager.topViewController()).present(height: screenHeight * 0.65)
    }
    
    static func showPickerWith(itemArray: Array<String>?, selectedIndex: Int , hintTitle: String? = nil, cancelAction: actionClosure?, confirmAction: @escaping pickerConfirmHandler) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: PickerViewController.self)) as! PickerViewController
        vc.setupVCWith(itemArray: itemArray, selectedIndex: selectedIndex , hintTitle: hintTitle, cancelAction: cancelAction, confirmAction: confirmAction)
        let height = (SizeTool.isIphone5()) ? screenHeight * 0.4 : screenHeight * 0.35
        VerticalPresentationController(presentedViewController: vc, presenting: SystemManager.topViewController()).present(height: height)
    }
    
    static func showYearMonthPickerWith(cancelAction: actionClosure?, confirmAction: @escaping yearMonthPickerConfirmHandler) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: YearMonthPickerViewController.self)) as! YearMonthPickerViewController
        vc.setupVcWith(cancelAction: cancelAction, confirmAction: confirmAction)
        let height = (SizeTool.isIphone5()) ? screenHeight * 0.4 : screenHeight * 0.35
        VerticalPresentationController(presentedViewController: vc, presenting: SystemManager.topViewController()).present(height: height)
    }
    
    static func showCalendarWith(shouldNotSelectDayArray: [Date]?, cancelAction:actionClosure?, confirmAction: @escaping calendarConfirmHandler) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: ShareCalendarViewController.self)) as! ShareCalendarViewController
        let width: CGFloat = screenWidth - 10.0 * 2 - 25.0 * 2
        let margin: CGFloat = 3.0 // 日曆與左右邊界的距離
        let cellSpace: CGFloat = margin * 2 // 每個item左右的距離(item上下距離為0)
        let cellWidth = (width - (margin * 2 + cellSpace * 6)) / 7 // 計算每個cell的寬度
        let height: CGFloat = cellWidth * 6 + (12 + 50) + (30 + 10) + (40 + 10)
        vc.setupVCWith(shouldNotSelectDayArray:shouldNotSelectDayArray, cancelAction: cancelAction, confirmAction: confirmAction)
        AlertPresentationController(presentedViewController: vc, presenting: SystemManager.topViewController()).present(height: height)
    }
    
    static func showCalendarWith(canSelectDayArray: [Date], cancelAction: actionClosure?, confirmAction: @escaping calendarConfirmHandler) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: ShareCalendarViewController.self)) as! ShareCalendarViewController
        let width: CGFloat = screenWidth - 10.0 * 2 - 25.0 * 2
        let margin: CGFloat = 3.0 // 日曆與左右邊界的距離
        let cellSpace: CGFloat = margin * 2 // 每個item左右的距離(item上下距離為0)
        let cellWidth = (width - (margin * 2 + cellSpace * 6)) / 7 // 計算每個cell的寬度
        let height: CGFloat = cellWidth * 6 + (12 + 50) + (30 + 10) + (40 + 10)
        vc.setupVCWith(canSelectDayArray: canSelectDayArray, cancelAction: cancelAction, confirmAction: confirmAction)
        AlertPresentationController(presentedViewController: vc, presenting: SystemManager.topViewController()).present(height: height)
    }
    
    static func showTransactionClauseWith(action:actionClosure?) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: TextViewAlertViewController.self)) as! TextViewAlertViewController
        vc.setupVCWith(image: UIImage.init(named: "img_money"), title: LocalizedString("Lang_LI_008"), textViewText: "11交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款交易條款", buttonTitle: LocalizedString("Lang_GE_001"), buttonAction: action)
        AlertPresentationController(presentedViewController: vc, presenting: SystemManager.topViewController()).present(height: screenHeight * 0.78, needDismissGesture: false)
    }
    
    static func showImagePickerWith(selectAssets: [MultipleAsset]?, maxSelectCount: Int = 5, showVideo: Bool = true, target: MultipleSelectImageViewControllerDelegate?) {
        let pickerController = MultipleSelectImageViewController()
        pickerController.UIDelegate = CustomUIDelegate()
        pickerController.showsCancelButton = true
        pickerController.showsEmptyAlbums = false
        pickerController.assetType = (showVideo) ? .allAssets : .allPhotos
        pickerController.maxSelectableCount = maxSelectCount
        
        if let selectAssets = selectAssets {
            pickerController.select(assets: selectAssets)
        }
        
        if showVideo {
            DKImageExtensionController.registerExtension(extensionClass: CustomCameraExtension.self, for: .camera)
        } else {
            DKImageExtensionController.unregisterExtension(for: .camera)
        }
        
        SystemManager.topViewController().present(pickerController, animated: true, completion: nil)
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            target?.didSelectAssets(MultipleAsset.transfer(assets))
        }
        
        pickerController.didCancel = {
            target?.didCancel()
        }
    }
    
    #if SALONMAKER
    static func showPortfolioImagePickerWith(selectAssets: [MultipleAsset]?, target: PortfolioImagePickerViewControllerDelegate?, disPlayType: DisplayCabinetType) {
        let pickerController = PortfolioImagePickerViewController()
        pickerController.UIDelegate = CustomUIDelegate()
        pickerController.showsCancelButton = true
        pickerController.showsEmptyAlbums = false
        pickerController.assetType = (disPlayType == .Video) ? .allVideos : .allPhotos
        pickerController.disPlayType = disPlayType
        
        if let selectAssets = selectAssets {
            pickerController.select(assets: selectAssets)
        }
        
        if disPlayType == .Video {
            DKImageExtensionController.registerExtension(extensionClass: CustomVideoCameraExtension.self, for: .camera)
        } else {
            DKImageExtensionController.unregisterExtension(for: .camera)
        }
        
        SystemManager.topViewController().present(pickerController, animated: true, completion: nil)
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            target?.didSelectAssets(assets: MultipleAsset.transfer(assets), displayType: pickerController.disPlayType, uploadPortfolioType: pickerController.uploadPortfolioType)
        }
        
        pickerController.didCancel = {
            target?.didCancel()
        }
    }
    #endif
    
    static func showTableViewWith(itemArray: [String], selectIndexArray: [Int], confirmAction: @escaping shareTableViewConfirmHandler) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: ShareTableViewController.self)) as! ShareTableViewController
        vc.setupVCWith(itemArray: itemArray, selectIndexArray: selectIndexArray, confirmAction: confirmAction)
        let height = screenHeight * 430 / 667
        VerticalPresentationController(presentedViewController: vc, presenting: SystemManager.topViewController()).present(height: height)
    }
    
    private static func calculateHeightWith(text: String, multiplying: CGFloat) -> CGFloat {
        return screenHeight * multiplying + text.height(withConstrainedWidth: screenWidth - 10.0 * 4, font: UIFont.systemFont(ofSize: 18.0))
    }
    
    private static func multiplying(_ type: AlertType) -> CGFloat {
        if type == .NoButton {
            if SizeTool.isIphone5() {
                return 0.25
            }
            if SizeTool.isIphone6() {
                return 0.21
            }
            if SizeTool.isIphone6Plus() {
                return 0.19
            }
            if SizeTool.isIphoneX() {
                return 0.17
            }
            return 0.2
        } else {
            if SizeTool.isIphone5() {
                return 0.3
            }
            if SizeTool.isIphone6() {
                return 0.26
            }
            if SizeTool.isIphone6Plus() {
                return 0.24
            }
            if SizeTool.isIphoneX() {
                return 0.22
            }
            return 0.25
        }
    }
}
