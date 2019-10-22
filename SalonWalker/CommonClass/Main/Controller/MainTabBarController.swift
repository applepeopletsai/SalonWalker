//
//  MainTabBarController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/22.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    // MARK: Property
    private var tabBarItemModelArray: [MainTabBarItemModel] {
        var itemModelArray: [MainTabBarItemModel] = []
        let salonMaker: [[String]] = [["tabbar_main_selected",
                                      "tabbar_portfolio_selected",
                                      "tabbar_calendar_selected",
                                      "tabbar_account_selected"],
                                     ["tabbar_main_normal",
                                      "tabbar_portfolio_normal",
                                      "tabbar_calendar_normal",
                                      "tabbar_account_normal"]]
        let salonWalker: [[String]] = [["tabbar_main_consumer_selected",
                                   "tabbar_haircut_selected",
                                   "tabbar_account_consumer_selected"],
                                  ["tabbar_main_consumer_normal",
                                   "tabbar_haircut_normal",
                                   "tabbar_account_consumer_normal"]]
        let array = (SystemManager.getAppIdentity() == .SalonWalker) ? salonWalker : salonMaker
        for i in 0..<array[0].count {
             itemModelArray.append(MainTabBarItemModel(selectImage: array[0][i], unSelectImage: array[1][i]))
        }
        return itemModelArray
    }
    
    private var navigationVCArray: [UINavigationController] {
        var vcArray: [UINavigationController] = []
        let salonMaker: [[String]] = [[kStory_StoreHomePage, kStory_StorePortfolio, "Shared", kStory_StoreAccount],
                                     [kVC_StoreHomePage,kVC_StorePortfolio,String(describing: MyCalendarViewController.self),kVC_StoreAccount]]
        let salonWalker: [[String]] = [[kStory_HomePage, kStory_HairCut, kStory_Account],
                                    [kVC_HomePage,kVC_HairCut,kVC_Account]]
        
        let array = (SystemManager.getAppIdentity() == .SalonWalker) ? salonWalker : salonMaker
        for i in 0..<array[0].count {
            // 切換target時如果crash，請clean後再build
            let vc = UINavigationController(rootViewController: UIStoryboard(name: array[0][i], bundle: nil).instantiateViewController(withIdentifier: array[1][i]))
            vc.isNavigationBarHidden = true
            vcArray.append(vc)
        }
        return vcArray
    }
    
    private var launchImageView: UIImageView?
    var customTabBar = MainTabBar()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        addObserver()
        
        if SystemManager.getAppIdentity() == .SalonWalker {
            apiGetCityCode()
            apiGetPhoneCode()
            setupLaunchImage()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                self?.apiGetSystemVersion()
            })
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Method
    private func autoLogin() {
        if let lastLoginType = UserManager.getLastLoginType() {
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
        }
    }
    
    private func setupLaunchImage() {
        self.launchImageView = UIImageView(frame: self.view.bounds)
        self.launchImageView?.image = UIImage(named: "A_000-0_形象頁")
        self.launchImageView?.contentMode = .scaleAspectFill
        self.launchImageView?.clipsToBounds = true
        view.addSubview(self.launchImageView!)
    }
    
    private func removeLaunchImageView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.launchImageView?.alpha = 0
        }) { (finish) in
            self.launchImageView?.removeFromSuperview()
        }
    }
    
    private func setupWelcomeView() {
        if UserManager.getFirst() {
            view.addSubview(GuideView(type: .SalonWalker))
            UserManager.saveFirst(false)
        } else {
            autoLogin()
        }
    }
    
    private func setupTabBar() {
        self.viewControllers = navigationVCArray
        
        let color = (SystemManager.getAppIdentity() == .SalonWalker) ? color_3DF9B1 : color_1A1C69
        self.customTabBar = MainTabBar.initWith(frame: self.tabBar.bounds, tabBarItemModelArray: self.tabBarItemModelArray, backgroundColor: color, delegate: self)
        self.tabBar.addSubview(self.customTabBar)
        self.tabBar.backgroundColor = color
    }

    private func addObserver() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: UIDevice.current)
    }
    
    @objc func orientationChanged(_ note: Notification?) {
        // 重設UI frame
        var frame = self.tabBar.bounds

        if let items = self.tabBar.items {
            for i in 0..<items.count {
                if let view = items[i].value(forKey: "view") as? UIView {
                    let width = self.tabBar.frame.size.width / CGFloat(self.customTabBar.tabBarItemArray.count)
                    let height = view.frame.size.height + 1.0
                    let x = width * CGFloat(i)
                    let itemFrame = CGRect(x: x, y: 0, width: width, height: height)
                    self.customTabBar.tabBarItemArray[i].frame = itemFrame
                    frame.size.height = view.frame.size.height
                } 
            }
        }
        
        self.customTabBar.frame = frame
    }
    
    // MARK: API
    private func apiLogin_MemberWith(type: LoginType, email: String? = nil, password: String? = nil, fbUid: String? = nil, googleUid: String? = nil) {
        if SystemManager.isNetworkReachable(showBanner: false) {
            UserManager.sharedInstance.loginType = type
            
            MemberManager.apiLogin(email: email, password: password, fbUid: fbUid, googleUid: googleUid, success: { [weak self] (model) in
                
                if model?.syscode == 200 {
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
                    self?.apiGetSvcClause()
                }
            }, failure: { _ in })
        }
    }
    
    private func apiGetSystemVersion() {
        if SystemManager.isNetworkReachable() {
            SystemManager.showLoading()
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
                    SystemManager.hideLoading()
                } else {
                    SystemManager.endLoadingWith(model: model)
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
}

extension MainTabBarController: MainTabBarDelegate {
    
    func didSelectItemAt(_ index: Int) {
        if SystemManager.getAppIdentity() == .SalonWalker {
            if index == 1 || index == 2 {
                if !UserManager.isLoginSalonWalker() {
                    SystemManager.showMustLoginAlert()
                    return
                }
            }
        }
        
        if self.selectedIndex != index {
            self.selectedIndex = index
            customTabBar.selectIndex = index
        } else {
            if let navigations = self.viewControllers as? [UINavigationController] {
                let naviVC = navigations[self.selectedIndex]
                if naviVC.viewControllers.count > 1 {
                    naviVC.popToRootViewController(animated: true)
                } else {
                    print("滑至頂端")
                }
            }
        }
    }
}


