//
//  SignInViewController.swift
//  SalonWalker
//
//  Created by skywind on 2018/3/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class SignInViewController: BaseViewController {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var emailField: IBInspectableTextField!
    @IBOutlet weak var passwordField: IBInspectableTextField!
    @IBOutlet weak var signInButton: IBInspectableButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupColor()
        setupTextField()
    }
    
    private func setupColor() {
        if SystemManager.getAppIdentity() == .SalonWalker {
            colorView.backgroundColor = color_E1FFF4
        }else{
            colorView.backgroundColor = color_7A57FA
        }
    }
    
    private func setupTextField() {
        signInButton.backgroundColor = color_AAAAAA
        emailField.addTarget(self, action: #selector(textDidChange(_:)), for: .allEditingEvents)
        passwordField.addTarget(self, action: #selector(textDidChange(_:)), for: .allEditingEvents)
    }
    
    private func showSignInNameVC() {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: String(describing: SignInNameViewController.self))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        if let email = emailField.text, let password = passwordField.text {
            if email.count > 0 && password.count > 0 {
                self.signInButton.backgroundColor = color_1A1C69
                self.signInButton.isUserInteractionEnabled = true
            } else {
                self.signInButton.backgroundColor = color_AAAAAA
                self.signInButton.isUserInteractionEnabled = false
            }
        }
    }
    
    @IBAction func generalRegisterButtonPress(_ sender: Any) {
        if let email = emailField.text {
            if !email.validateEmail() {
                SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_LI_027"), alertMessage: LocalizedString("Lang_LI_028"), buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
                return
            }
        }
        if let password = passwordField.text {
            if !password.validatePassword() {
                SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_LI_029"), alertMessage: LocalizedString("Lang_LI_030"), buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
                return
            }
        }
        
        apiVerifyAccount(type: .general)
    }
    
    @IBAction private func fbRegisterButtonPress(_ sender: UIButton) {
        // 目前在ios 8上測試Facebook登入會crash by Daniel 2018/05/16
        /*
         2018/05/30更新：
         有將此問題回報給facebook團隊，他們的回覆如下:
         The team has looked into this issue but have not made this issue a priority for resolution.
         It seems like iOS 8 has a very small share of iOS traffic and hence it is no longer supported.
         Since this impacts a negligible user population, the team has decided to not look into fixing this.
         
         We apologise for the inconvenience and thank you for your understanding.
         
         Thanks.
         
         Urvashi
         
         大意就是：ios8 用戶數量太少，所以他們決定不修復此問題
         */
        if #available(iOS 9, *) {
            if SystemManager.isNetworkReachable() {
                self.showLoading()
                FBManager.loginWith(success: { [unowned self] in
                    self.hideLoading()
                    UserManager.sharedInstance.fbUid = FBManager.getUserId()
                    UserManager.sharedInstance.nickName = String(FBManager.getUserName().prefix(10))
                    self.apiVerifyAccount(type: .fb)
                    }, failure: {
                        self.hideLoading()
                })
            }
        } else {
            SystemManager.showAlertWith(alertTitle: "ios8不支援Facebook快速登入功能", alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
        }
    }
    
    @IBAction private func googleRegisterButtonPress(_ sender: UIButton) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            GoogleManager.loginWith(success: { [unowned self] in
                self.hideLoading()
                UserManager.sharedInstance.googleUid = GoogleManager.getUserId()
                UserManager.sharedInstance.nickName = String(GoogleManager.getUserName().prefix(10))
                self.apiVerifyAccount(type: .google)
            }, failure: {
                self.hideLoading()
            })
        }
    }
    
    // MARK: API
    private func apiVerifyAccount(type: LoginType) {
        if SystemManager.isNetworkReachable() {
            
            let email = (type == .general) ? emailField.text : nil
            let fbUid = (type == .fb) ? UserManager.sharedInstance.fbUid : nil
            let googleUid = (type == .google) ? UserManager.sharedInstance.googleUid : nil
            
            self.showLoading()
            
            if SystemManager.getAppIdentity() == .SalonWalker {
                MemberManager.apiVerifyMemberAccount(email: email, fbUid: fbUid, googleUid: googleUid, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        UserManager.sharedInstance.loginType = type
                        if type == .general {
                            UserManager.sharedInstance.email = email
                            UserManager.sharedInstance.password = self.passwordField.text
                            UserManager.sharedInstance.nickName = nil
                        }
                        self.showSignInNameVC()
                        self.hideLoading()
                    } else {
                        self.endLoadingWith(model: model)
                    }
                    }, failure: { (error) in
                        SystemManager.showErrorAlert(error: error)
                })
            } else {
                OperatingManager.apiVerifyOperatingAccount(email: email, fbUid: fbUid, googleUid: googleUid, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        UserManager.sharedInstance.loginType = type
                        if type == .general {
                            UserManager.sharedInstance.email = email
                            UserManager.sharedInstance.password = self.passwordField.text
                            UserManager.sharedInstance.nickName = nil
                        }
                        self.showSignInNameVC()
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
