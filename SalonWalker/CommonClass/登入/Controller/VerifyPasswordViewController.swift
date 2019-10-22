//
//  VerifyPasswordViewController.swift
//  SalonWalker
//
//  Created by skywind on 2018/3/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class VerifyPasswordViewController: BaseViewController {
    @IBOutlet weak var colorView: UIView!

    @IBOutlet private weak var textField: IBInspectableTextField!
    @IBOutlet private weak var sendButton: IBInspectableButton!
    @IBOutlet private weak var reSendButton: IBInspectableButton!
    
    private var phoneCode: String = ""
    private var phone: String = ""
    private var timer: Timer?
    private var time: Int = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupColor()
        setupButton()
        startTimer()
        setupTextField()
    }
    
    func setupVCWith(phoneCode: String, phone: String) {
        self.phoneCode = phoneCode
        self.phone = phone
    }
    
    private func setupTextField() {
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: .allEditingEvents)
    }
    
    private func setupButton() {
        sendButton.backgroundColor = color_AAAAAA
    }
    
    private func setupReSendButton() {
        time = 30
        reSendButton.setTitle(LocalizedString("Lang_LI_024") + "(\(String(time)))", for: .normal)
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
            self.sendButton.backgroundColor = (verify.count == 6) ? color_1A1C69 : color_AAAAAA
            self.sendButton.isUserInteractionEnabled = (verify.count == 6)
        }
    }
    
    func setupColor() {
        if SystemManager.getAppIdentity() == .SalonWalker {
            colorView.backgroundColor = color_E1FFF4
        }else{
            colorView.backgroundColor = color_7A57FA
        }
    }

    @IBAction func sendVerifyOnClick(_ sender: Any) {
        apiVerifyNum()
    }
    
    @IBAction private func resendButtonPress(_ sender: UIButton) {
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
    private func apiSendVerify() {
        if SystemManager.isNetworkReachable() {
            
            self.showLoading()
            
            if SystemManager.getAppIdentity() == .SalonWalker {
                MemberManager.apiSetVerify(confirmType: "2", internationalPrefix: phoneCode, phone: phone, success: { [unowned self] (model) in
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
                OperatingManager.apiSetVerify(confirmType: "2", internationalPrefix: phoneCode, phone: phone, success: { [unowned self] (model) in
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
                        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "ResetPasswordViewController")
                        self.navigationController?.pushViewController(vc, animated: true)
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
                        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "ResetPasswordViewController")
                        self.navigationController?.pushViewController(vc, animated: true)
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
