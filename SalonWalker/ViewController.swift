//
//  ViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/14.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ViewController: BaseViewController, PhotoToolDelegate, MultipleSelectImageViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func oneButtonPress(_ sender: UIButton) {
        PresentationTool.showOneButtonAlertWith(image: UIImage.init(named: "btn_add"), message: "測試\n測試\n測試測試\n測試測試測試測試\n測試\n測試測試\n測試測試測試測試\n測試\n測試測試\n測試測試測試測試\n測試\n測試測試\n測試測試測試\n測試測試測試測試\n測試\n測試測試\n測試測試測試測試\n測試\n測試測試\n測試測試測試", buttonTitle: "ok", buttonAction: nil)
    }
    
    @IBAction func twoButtonPress(_ sender: UIButton) {
        PresentationTool.showTwoButtonAlertWith(image: UIImage(named: "logo__store"), message: "test\ntest", leftButtonTitle: "ok", leftButtonAction: nil, rightButtonTitle: "no", rightButtonAction: nil)
    }
    
    @IBAction func timePickerButtonPress(_ sender: UIButton) {
        PresentationTool.showPickerWith(itemArray: ["07:00","08:00","09:00","10:00","11:00"], selectedIndex: 2, cancelAction: nil, confirmAction: { (item, index) in
            print(item)
            print(index)
        })
    }
    
    @IBAction func calendarButtonPress(_ sender: UIButton) {
        let array = [Date.from(year: 2018, month: 1, day: 10),
                     Date.from(year: 2018, month: 1, day: 25),
                     Date.from(year: 2018, month: 2, day: 5),
                     Date.from(year: 2018, month: 2, day: 19),
                     Date.from(year: 2018, month: 3, day: 7),
                     Date.from(year: 2018, month: 3, day: 21)]
        PresentationTool.showCalendarWith(shouldNotSelectDayArray:array, cancelAction: nil, confirmAction: { (date) in
            print(date)
        })
    }
    
    @IBAction func noButtonPress(_ sender: UIButton) {
        PresentationTool.showNoButtonAlertWith(image: UIImage(named: "logo__store"), message: "測試自動消失測試自動消失\n測試", completion: {
            print("測試")
        })
    }
    
    @IBAction func fbLoginButtonPress(_ sender: UIButton) {
        FBManager.loginWith(success: {
            print(FBManager.getUserName())
            print(FBManager.getEmail())
        }, failure: {
            
        })
    }
    
    @IBAction func googlLoginButtonPress(_ sender: UIButton) {
        GoogleManager.loginWith(success: {
            print(GoogleManager.getUserName())
            print(GoogleManager.getEmail())
        }, failure: {
            
        })
    }
    
    @IBAction func photoButtonPress(_ sender: UIButton) {
        PhotoTool.getImageWith(delegate: self)
    }
    
    var selectAssets: [MultipleAsset]? = []
    @IBAction func multiplePhotoButtonPress(_ sender: UIButton) {
        PresentationTool.showImagePickerWith(selectAssets: selectAssets, target: self)
    }
    
    #if SALONMAKER
    @IBAction func portolioImageViewVC(_ sender: UIButton) {
        PresentationTool.showPortfolioImagePickerWith(selectAssets: selectAssets, target: self, disPlayType: .Video)
    }
    #endif
    
    // PhotoToolDelegate
    func didGetImage(_ image: UIImage) {
        print(image)
    }
    
    // MultipleSelectImageViewControllerDelegate
    func didSelectAssets(_ assets: [MultipleAsset]) {
        self.selectAssets = assets
    }
    
    func didCancel() {
        print("Cancel")
    }
}

#if SALONMAKER
extension ViewController: PortfolioImagePickerViewControllerDelegate {
    
    func didSelectAssets(assets: [MultipleAsset], displayType: DisplayCabinetType, uploadPortfolioType: UploadPortfolioType) {
        print("disPlayType: \(displayType)")
        print("uploadPortfolioType: \(uploadPortfolioType)")
    }
}
#endif
