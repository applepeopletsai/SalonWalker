//
//  EnterVerifyViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/27.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class EnterVerifyViewController: BaseViewController {

    @IBOutlet private weak var textField: IBInspectableTextField!
    @IBOutlet private weak var sendVerifyButton: IBInspectableButton!
    @IBOutlet private weak var reSendButton: IBInspectableButton!
    @IBOutlet private weak var agreeTermsLabel: UILabel!
    
    private var phoneCode: String = ""
    private var phone: String = ""
    private var timer: Timer?
    private var time: Int = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        setupButton()
        setupReSendButton()
        setupLabel()
        startTimer()
    }
    
    func setupVCWith(phoneCode: String, phone: String) {
        self.phoneCode = phoneCode
        self.phone = phone
    }
    
    private func setupTextField() {
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: .allEditingEvents)
    }
    
    private func setupButton() {
        sendVerifyButton.backgroundColor = color_AAAAAA
    }
    
    private func setupReSendButton() {
        time = 30
        reSendButton.setTitle(LocalizedString("Lang_LI_024") + "(\(String(time)))", for: .normal)
    }
    
    private func setupLabel() {
        let text = LocalizedString("Lang_LI_021")
        let attributedString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: LocalizedString("Lang_RD_010"))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color_1A1C69, range: range)
        self.agreeTermsLabel.attributedText = attributedString
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        self.agreeTermsLabel.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func tap(_ gesture: UITapGestureRecognizer) {
        if gesture.didTapSpecificText(text: LocalizedString("Lang_RD_010"), onLabel: self.agreeTermsLabel) {
            SystemManager.openServiceTerms()
        }
    }
    
    private func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateReSendButtonTitle), userInfo: nil, repeats: true)
    }
    
    @objc private func updateReSendButtonTitle() {
        time -= 1
        let second = (time == -1) ? "" : "(\(String(time)))"
        reSendButton.setTitle(LocalizedString("Lang_LI_024") + second, for: .normal)
        
        if time == -1 {
            timer?.invalidate()
        }
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        if let verify = textField.text {
            self.sendVerifyButton.backgroundColor = (verify.count == 6) ? color_1A1C69 : color_AAAAAA
            self.sendVerifyButton.isUserInteractionEnabled = (verify.count == 6) ? true : false
        }
    }

    @IBAction private func sendVerifyCodeButtonPress(_ sender: IBInspectableButton) {
        apiVerifyNum()
    }
    
    @IBAction private func resendButtonPress(_ sender: IBInspectableButton) {
        if time > 0 {
            SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_LI_025"), alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
            return
        }
        
        apiSendVerify()
    }
    
    @IBAction private func naviBackButtonPress(_ sender: UIButton) {
        if timer != nil { timer?.invalidate() }
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: API
    private func apiRegister_member() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            let email = (UserManager.sharedInstance.loginType == .general) ? UserManager.sharedInstance.email : nil
            let password = (UserManager.sharedInstance.loginType == .general) ? UserManager.sharedInstance.password : nil
            let fbUid = (UserManager.sharedInstance.loginType == .fb) ? UserManager.sharedInstance.fbUid : nil
            let googleUid = (UserManager.sharedInstance.loginType == .google) ? UserManager.sharedInstance.googleUid : nil
            
            MemberManager.apiRegister(email: email, password: password, fbUid: fbUid, googleUid: googleUid, nickName: UserManager.sharedInstance.nickName!, tempImgId: nil, success: { [weak self] (model) in
                
                if model?.syscode == 200 {
                    if let userToken = model?.data?.userToken {
                        UserManager.saveUserToken(userToken)
                    }
                    
                    if let penalty = model?.data?.penalty {
                        UserManager.sharedInstance.penalty = penalty
                    }
                    
                    UserManager.saveUserData()
                    if self?.timer != nil { self?.timer?.invalidate() }
                    self?.hideLoading()
                    self?.dismiss(animated: true, completion: nil)
                } else {
                    self?.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiRegister_operating() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            let email = (UserManager.sharedInstance.loginType == .general) ? UserManager.sharedInstance.email : nil
            let password = (UserManager.sharedInstance.loginType == .general) ? UserManager.sharedInstance.password : nil
            let fbUid = (UserManager.sharedInstance.loginType == .fb) ? UserManager.sharedInstance.fbUid : nil
            let googleUid = (UserManager.sharedInstance.loginType == .google) ? UserManager.sharedInstance.googleUid : nil
            
            OperatingManager.apiRegister(email: email, password: password, fbUid: fbUid, googleUid: googleUid, nickName: UserManager.sharedInstance.nickName!, tempImgId: nil, success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    if let userToken = model?.data?.userToken {
                        UserManager.saveUserToken(userToken)
                    }
                    
                    #if SALONMAKER
                    if UserManager.sharedInstance.userIdentity == .designer {
                        let vc = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "DesignerRegisterViewController") as! DesignerRegisterViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "StoreRegisterViewController") as! StoreRegisterViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    #else
                    #endif
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiSendVerify() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            if SystemManager.getAppIdentity() == .SalonWalker {
                MemberManager.apiSetVerify(confirmType: "1", internationalPrefix: phoneCode, phone: phone, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        if let mId = model?.data?.mId {
                            UserManager.sharedInstance.mId = mId
                        }
                        SystemManager.showAlertWith(alertTitle: model?.data?.msg, alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: {
                            self.setupReSendButton()
                            self.startTimer()
                        })
                        self.hideLoading()
                    } else {
                        self.endLoadingWith(model: model)
                    }
                    }, failure: { (error) in
                        SystemManager.showErrorAlert(error: error)
                })
            } else {
                OperatingManager.apiSetVerify(confirmType: "1", internationalPrefix: phoneCode, phone: phone, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        if let ouId = model?.data?.ouId {
                            UserManager.sharedInstance.ouId = ouId
                        }
                        SystemManager.showAlertWith(alertTitle: model?.data?.msg, alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: {
                            self.setupReSendButton()
                            self.startTimer()
                        })
                        self.hideLoading()
                    } else {
                        self.endLoadingWith(model: model)
                    }
                    }, failure: { (error) in
                        SystemManager.showErrorAlert(error: error)
                })
            }
        }
    }
    
    private func apiVerifyNum() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            if SystemManager.getAppIdentity() == .SalonWalker {
                
                MemberManager.apiVerifyNum(num: textField.text!, success: { [unowned self] (model) in
                    
                    if model?.syscode == 200 {
                        self.apiRegister_member()
                        self.hideLoading()
                    } else {
                        self.endLoadingWith(model: model)
                    }
                    }, failure: { (error) in
                        SystemManager.showErrorAlert(error: error)
                })
            } else {
                OperatingManager.apiVerifyNum(num: textField.text!, success: { [unowned self] (model) in
                    
                    if model?.syscode == 200 {
                        self.apiRegister_operating()
                        self.hideLoading()
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
