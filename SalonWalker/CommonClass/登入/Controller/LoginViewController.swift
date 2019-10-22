//
//  LoginViewController.swift
//  SalonWalker
//
//  Created by skywind on 2018/2/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum LoginType: String {
    case general = "general", fb = "fb", google = "google"
}

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var userNameField: IBInspectableTextField!
    @IBOutlet weak var passwordField: IBInspectableTextField!
    @IBOutlet weak var loginButton: IBInspectableButton!
    @IBOutlet weak var emailTextFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var googleLoginButtonBottomConstraint: NSLayoutConstraint!
    
    private var launchImageView: UIImageView?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        resetColorViewHeight()
        
        if SystemManager.getAppIdentity() == .SalonMaker {
            apiGetCityCode()
            apiGetPhoneCode()
            setupLaunchImage()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                self?.apiGetSystemVersion()
            })
            dismissButton.isHidden = true
        } else {
            dismissButton.isHidden = false
        }
    }
    
    // MARK: Method
    private func autoLogin() {
        if let lastLoginType = UserManager.getLastLoginType() {
            if SystemManager.getAppIdentity() == .SalonWalker {
                switch lastLoginType {
                case .general:
                    if let email = UserManager.getEmail(), let password = UserManager.getPassword() {
                        apiLogin_MemberWith(type: .general, email: email, password
                            : password)
                    }
                    break
                case .fb:
                    if let fbUid = UserManager.getFbUid() {
                        apiLogin_MemberWith(type: .fb, fbUid: fbUid)
                    }
                    break
                case .google:
                    if let googleUid = UserManager.getGoogleUid() {
                        apiLogin_MemberWith(type: .google, googleUid: googleUid)
                    }
                    break
                }
            } else {
                switch lastLoginType {
                case .general:
                    if let email = UserManager.getEmail(), let password = UserManager.getPassword() {
                        apiLogin_OperatingWith(type: .general, email: email, password: password)
                    }
                    break
                case .fb:
                    if let fbUid = UserManager.getFbUid() {
                        apiLogin_OperatingWith(type: .fb, fbUid: fbUid)
                    }
                    break
                case .google:
                    if let googleUid = UserManager.getGoogleUid() {
                        apiLogin_OperatingWith(type: .google, googleUid: googleUid)
                    }
                    break
                }
            }
        }
    }
    
    private func setupLaunchImage() {
        let image = (SystemManager.getAppIdentity() == .SalonWalker) ? "A_000-0_形象頁" : "B_000"

        self.launchImageView = UIImageView(frame: self.view.bounds)
        self.launchImageView?.contentMode = .scaleAspectFill
        self.launchImageView?.clipsToBounds = true
        self.launchImageView?.image = UIImage(named: image)
        view.addSubview(self.launchImageView!)
    }
    
    private func resetColorViewHeight() {
        if SizeTool.isIphone6Plus() {
            emailTextFieldTopConstraint.constant = 50 + 37
            googleLoginButtonBottomConstraint.constant = 50 + 37
        }
        
        if SizeTool.isIphoneX() {
            emailTextFieldTopConstraint.constant = 50 + 45
            googleLoginButtonBottomConstraint.constant = 50 + 45
        }
    }
    
    private func removeLaunchImageView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.launchImageView?.alpha = 0
        }) { (finish) in
            self.launchImageView?.removeFromSuperview()
        }
    }
    
    private func setupWelcomeView() {
        if SystemManager.getAppIdentity() == .SalonWalker {
            colorView.backgroundColor = color_E1FFF4
            if UserManager.getFirst() {
                view.addSubview(GuideView(type: .SalonWalker))
                UserManager.saveFirst(false)
            } else {
                autoLogin()
            }
        } else {
            colorView.backgroundColor = color_7A57FA
            if UserManager.getFirst() {
                view.addSubview(GuideView(type: .SalonMaker))
                UserManager.saveFirst(false)
            } else {
                autoLogin()
            }
        }
    }
    
    private func setupTextField() {
        loginButton.backgroundColor = color_AAAAAA
        userNameField.addTarget(self, action: #selector(textDidChange(_:)), for: .allEditingEvents)
        passwordField.addTarget(self, action: #selector(textDidChange(_:)), for: .allEditingEvents)
        
        if let email = UserManager.getEmail() {
            userNameField.text = email
            textDidChange(userNameField)
        }
        if let password = UserManager.getPassword() {
            passwordField.text = password
            textDidChange(passwordField)
        }
    }
    
    private func loginSuccessHandler() {
        apiGetSvcClause()
        if SystemManager.getAppIdentity() == .SalonWalker {
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRefreshUIAfterLoginout), object: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    RemoteNotificationManager.handleRemoteNotification()
                    SystemManager.handleDeepLink()
                })
            })
        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
            self.present(vc, animated: true, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    RemoteNotificationManager.handleRemoteNotification()
                    SystemManager.handleDeepLink()
                })
            })
        }
    }
    
    private func goToRegister() {
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
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        if let email = userNameField.text, let password = passwordField.text {
            if email.count > 0 && password.count > 0 {
                self.loginButton.backgroundColor = color_1A1C69
                self.loginButton.isUserInteractionEnabled = true
            } else {
                self.loginButton.backgroundColor = color_AAAAAA
                self.loginButton.isUserInteractionEnabled = false
            }
        }
    }
    
    override func networkDidRecover() {
        if self.launchImageView?.alpha != 0 {
            apiGetSystemVersion()
            apiGetCityCode()
            apiGetPhoneCode()
            apiGetSvcClause()
        }
    }
    
    //MARK: Event Handler
    @IBAction func loginOnClick(_ sender: Any) {
        if let email = userNameField.text {
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

        if SystemManager.getAppIdentity() == .SalonWalker {
            apiLogin_MemberWith(type: .general, email: userNameField.text, password: passwordField.text)
        } else {
            apiLogin_OperatingWith(type: .general, email: userNameField.text, password: passwordField.text)
        }
    }
    
    @IBAction func fbLoginOnClick(_ sender: Any) {
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
                    if SystemManager.getAppIdentity() == .SalonWalker {
                        self.apiLogin_MemberWith(type: .fb, fbUid: UserManager.sharedInstance.fbUid)
                    } else {
                        self.apiLogin_OperatingWith(type: .fb, fbUid: UserManager.sharedInstance.fbUid)
                    }
                    }, failure: {
                        self.hideLoading()
                })
            }
        } else {
            SystemManager.showAlertWith(alertTitle: "ios8不支援Facebook快速登入功能", alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
        }
    }
    
    @IBAction func googleLoginOnClick(_ sender: Any) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            GoogleManager.loginWith(success: {
                self.hideLoading()
                UserManager.sharedInstance.googleUid = GoogleManager.getUserId()
                UserManager.sharedInstance.nickName = String(GoogleManager.getUserName().prefix(10))
                if SystemManager.getAppIdentity() == .SalonWalker {
                    self.apiLogin_MemberWith(type: .google, googleUid: UserManager.sharedInstance.googleUid)
                } else {
                    self.apiLogin_OperatingWith(type: .google, googleUid: UserManager.sharedInstance.googleUid)
                }
            }, failure: {
                self.hideLoading()
            })
        }
    }
    
    @IBAction func forgotPasswordOnClick(_ sender: Any) {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func signInOnClick(_ sender: Any) {
        if SystemManager.getAppIdentity() == .SalonWalker {
            let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController")
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "IdentityViewController") as! IdentityViewController
            vc.setupVCWithType(.general)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction private func dismissButtonPress(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                RemoteNotificationManager.handleRemoteNotification()
                SystemManager.handleDeepLink()
            })
        })
    }
    
    // MARK: API
    private func apiGetSystemVersion() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            SystemManager.apiGetVersion(success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    switch model?.data?.upgrade {
                    case 0:
                        self.removeLaunchImageView()
                        self.setupWelcomeView()
                        break
                    case 1:
                        SystemManager.showTwoButtonAlertWith(alertTitle: LocalizedString("Lang_GE_002"), alertMessage: nil, leftButtonTitle: LocalizedString("Lang_GE_003"), rightButtonTitle: LocalizedString("Lang_GE_004"), leftHandler: {
                        }, rightHandler: {
                            self.removeLaunchImageView()
                            self.setupWelcomeView()
                        })
                        break
                    case 2:
                        SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_GE_002"), alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_003"), handler: {
                        })
                        break
                    default: break
                    }
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }

    private func apiGetCityCode() {
        if SystemManager.isNetworkReachable(showBanner: false) {
            SystemManager.apiGetCityCode(success: { (model) in
                if model?.syscode == 200 {
                    if let cityCodeModel = model?.data {
                        SystemManager.saveCityCodeModel(cityCodeModel)
                    }
                }
            }, failure: { _ in })
        }
    }
    
    private func apiGetPhoneCode() {
        if SystemManager.isNetworkReachable(showBanner: false) {
            SystemManager.apiGetPhoneCode(success: { (model) in
                if let phoneCodeModel = model?.data {
                    SystemManager.savePhoencodeModel(phoneCodeModel)
                }
            }, failure: { _ in })
        }
    }
    
    private func apiGetSvcClause() {
        if SystemManager.isNetworkReachable(showBanner: false) {
            SystemManager.apiGetSvcClause(success: { (model) in
                UserManager.sharedInstance.svcClause = model?.data?.svcClause
            }, failure: { _ in})
        }
    }
    
    private func apiLogin_MemberWith(type: LoginType, email: String? = nil, password: String? = nil, fbUid: String? = nil, googleUid: String? = nil) {
        if SystemManager.isNetworkReachable() {
            UserManager.sharedInstance.loginType = type
            
            self.showLoading()
            MemberManager.apiLogin(email: email, password: password, fbUid: fbUid, googleUid: googleUid, success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    self.hideLoading()
                    UserManager.sharedInstance.email = email
                    UserManager.sharedInstance.password = password
                    UserManager.sharedInstance.mId = model?.data?.mId
                    UserManager.sharedInstance.nickName = model?.data?.nickName
                    UserManager.sharedInstance.penalty = model?.data?.penalty
                    
                    if let userToken = model?.data?.userToken {
                        UserManager.saveUserToken(userToken)
                    }
                    
                    if let status = model?.data?.status {
                        /*
                         帳號狀態：
                         0:未註冊
                         1:啟用
                         2:暫停使用 - 因違反使用規定，暫時無法使用預約功能
                         3:停權 - 永久停權
                         9:刪除
                         */
                        // status為0，API的syscode非200
                        UserManager.sharedInstance.accountStatus = AccountStatus(rawValue: status)
                    }
                    UserManager.saveUserData()
                    self.loginSuccessHandler()
                } else {
                    self.endLoadingWith(model: model)
                }
                
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiLogin_OperatingWith(type: LoginType, email: String? = nil, password: String? = nil, fbUid: String? = nil, googleUid: String? = nil) {
        if SystemManager.isNetworkReachable() {
            UserManager.sharedInstance.loginType = type
            
            self.showLoading()
            OperatingManager.apiLogin(email: email, password: password, fbUid: fbUid, googleUid: googleUid, success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    self.hideLoading()
                    UserManager.sharedInstance.email = email
                    UserManager.sharedInstance.password = password
                    UserManager.sharedInstance.ouId = model?.data?.ouId
                    UserManager.sharedInstance.nickName = model?.data?.nickName
                    UserManager.sharedInstance.penalty = model?.data?.penalty
                    UserManager.sharedInstance.userIdentity = (model?.data?.ouType == "Designer") ? .designer : .store
                    
                    if let userToken = model?.data?.userToken {
                        UserManager.saveUserToken(userToken)
                    }
                    
                    if let status = model?.data?.status {
                        /*
                         帳號狀態：
                         0 :未註冊
                         1 :啟用
                         2 :暫停使用 - 因違反使用規定，暫時無法使用預約功能
                         3 :停權 - 永久停權
                         4 :註冊未完成 - 設計師 / 業主尚未填寫個人資料
                         5 :審核中 - 設計師 / 業主已填寫個人資料，後台審核中
                         6 :待上架 - 設計師 / 業主尚未填寫服務資訊
                         9 :刪除
                         */
                        // status為0與5，API的syscode非200
                        UserManager.sharedInstance.accountStatus = AccountStatus(rawValue: status)
                        switch status {
                        case 1,2,3,6:
                            UserManager.saveUserData()
                            self.loginSuccessHandler()
                            break
                        case 4:
                            self.goToRegister()
                            break
                        default: break
                        }
                    }
                } else {
                    self.endLoadingWith(model: model)
                }
                
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
}
