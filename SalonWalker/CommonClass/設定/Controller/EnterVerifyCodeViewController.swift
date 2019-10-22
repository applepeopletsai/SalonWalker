//
//  EnterVerifyCodeViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/19.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

let kChangePhoneNumber = "ChangePhoneNumber"

class EnterVerifyCodeViewController: BaseViewController {

    @IBOutlet weak var verifyCodeTextField: IBInspectableTextField!
    
    private var internationalPrefix = ""
    private var phoneNum = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Method
    func setupVCWith(internationalPrefix: String , phoneNum: String) {
        self.internationalPrefix = internationalPrefix
        self.phoneNum = phoneNum
    }
    
    // MARK: Event Handler
    @IBAction func dismissButtonClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonClick(_ sender: UIButton) {
        if verifyCodeTextField.text?.count == 0 {
            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_LI_012"), body: "")
            return
        }
        verifyNum()
    }
    
    // MARK: API
    private func verifyNum() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            if UserManager.sharedInstance.userIdentity == .consumer {
                MemberManager.apiVerifyNum(num: verifyCodeTextField.text!, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        self.hideLoading()
                        self.apiSetPhone()
                    } else {
                        self.endLoadingWith(model: model)
                    }
                    }, failure: { (error) in
                        SystemManager.showErrorAlert(error: error)
                })
            } else {
                OperatingManager.apiVerifyNum(num: verifyCodeTextField.text!, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        self.hideLoading()
                        self.apiSetPhone()
                    } else {
                        self.endLoadingWith(model: model)
                    }
                    }, failure: { (error) in
                        SystemManager.showErrorAlert(error: error)
                })
            }
        }
    }
    
    private func apiSetPhone() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            if UserManager.sharedInstance.userIdentity == .consumer {
                MemberManager.apiSetMemberPhone(internationalPrefix: internationalPrefix, phone: phoneNum, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        self.hideLoading()
                        let dic = ["internationalPrefix":self.internationalPrefix,"phone":self.phoneNum]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kChangePhoneNumber), object: nil, userInfo: dic)
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    } else {
                        self.endLoadingWith(model: model)
                    }
                    }, failure: { (error) in
                        SystemManager.showErrorAlert(error: error)
                })
            } else {
                OperatingManager.apiSetOperatingPhone(internationalPrefix: internationalPrefix, phone: phoneNum, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        self.hideLoading()
                        let dic = ["internationalPrefix":self.internationalPrefix,"phone":self.phoneNum]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kChangePhoneNumber), object: nil, userInfo: dic)
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    } else {
                        self.endLoadingWith(model: model)
                    }
                    }, failure: { (error) in
                        SystemManager.showErrorAlert(error: error)
                })
            }
        }
    }
}
