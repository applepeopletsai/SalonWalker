//
//  AppDelegate.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/14.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import UserNotifications
import FBSDKCoreKit
import GoogleSignIn
import IQKeyboardManagerSwift
import GoogleMaps
import Branch
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // NetworkMonitoring
        SystemManager.startNetworkMonitoring()
        
        // 隱藏TabBar上方的線
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        
        // 消除小紅點
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        #if SALONMAKER
        SystemManager.saveAppIdentity(.SalonMaker)
        #else
        SystemManager.saveAppIdentity(.SalonWalker)
        UserManager.sharedInstance.userIdentity = .consumer
        #endif
        
        // FB
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Google
        #if SALONMAKER
        GIDSignIn.sharedInstance().clientID = "722397632055-s87b9tdaaf782pf0jg0pecrgu719m3lr.apps.googleusercontent.com"
        #else
        GIDSignIn.sharedInstance().clientID = "722397632055-jnemv954vmrq6c4leo53aiqlorurcjvv.apps.googleusercontent.com"
        #endif
        GMSServices.provideAPIKey("AIzaSyAE97CduWGY0ZgcJVnGys06mSXaen8yUpo")
        
        // FireBase
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        #if DEBUG
        Fabric.sharedSDK().debug = true
        #endif
        
        // IQKeyBoard
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        
        // 註冊推播
        registerPushNotifications()
        
        // Location
//        LocationManager.updateLocation()
        
        // ios8,9 未啟動時點擊推播
        handleReceiveRemoteNotification_ios8_ios9(launchOptions: launchOptions)
        
        // Branch
        #if DEV || UAT
        Branch.setUseTestBranchKey(true)
        #endif
        
        handleBranch(launchOptions: launchOptions)
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
    }
    
    // ios8,9 當app在背景收到推播並點擊時觸發
    // 如果在未啟動app時點擊推播，推播內容會在didFinishLaunchingWithOptions中(不會觸發此function)
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        Branch.getInstance().handlePushNotification(userInfo)
        
        if let extraPayLoad = userInfo["extraPayLoad"] as? [String:Any] {
            if let order = extraPayLoad["order"] as? [String:Any] {
                print("order: \(order)")
                handleReceiveRemoteNotification(userInfo: order)
                // 更新訂單記錄列表
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kShouldReloadOrderRecord), object: nil)
            } else if let infoData = extraPayLoad["infoData"] as? [String:Any] {
                print("infoData: \(infoData)")
                handleReceiveRemoteNotification(userInfo: infoData)
            }
        }
    }
    
    // ios8,9 在前景時收到推播直接觸發
    // 如果想要在前景也顯示推播內容，則必須要自行做一個alert
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let aps = userInfo["aps"] as? [AnyHashable : Any], let alert = aps["alert"] as? [AnyHashable : Any], let title = alert["title"] as? String, let body = alert["body"] as? String {
            if !(SystemManager.topViewController() is LoginViewController) {
                SystemManager.showAlertWith(alertTitle: title, alertMessage: body, buttonTitle: LocalizedString("Lang_GE_005"), handler: {
                    self.application(application, didReceiveRemoteNotification: userInfo)
                })
            } else {
                self.application(application, didReceiveRemoteNotification: userInfo)
            }
            completionHandler(UIBackgroundFetchResult.noData)
        }
    }
    
    private func handleReceiveRemoteNotification_ios8_ios9(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let noti = launchOptions?[.remoteNotification] as? [String:Any], let extraPayLoad = noti["extraPayLoad"] as? [String:Any] {
            if let order = extraPayLoad["order"] as? [String:Any] {
                print("order: \(order)")
                handleReceiveRemoteNotification(userInfo: order)
            } else if let infoData = extraPayLoad["infoData"] as? [String:Any] {
                print("infoData: \(infoData)")
                handleReceiveRemoteNotification(userInfo: infoData)
            }
        }
    }
    
    // ios9以上
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let fbHandler = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])

        let googleHandler = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])
        
        let branchHandler = Branch.getInstance().application(app, open: url, options: options)
        
        return fbHandler || googleHandler || branchHandler
    }

    // ios8
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let fbHandler = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        let googleHandler = GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
        
        let branchHandler = Branch.getInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        return fbHandler || googleHandler || branchHandler
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("") {
            return $0 + String(format: "%02x", $1)
        }
        UserManager.savePushToken(deviceTokenString)
        print("=== deviceTokenString: \(deviceTokenString)")
    }
    
    private func registerPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
                if granted {
                    debugPrint("=== 使用者同意推播通知")
                } else {
                    debugPrint("=== 使用者不同意推播通知")
                }
            }
            UNUserNotificationCenter.current().delegate = self
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
    
    private func handleBranch(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        Branch.getInstance().initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { (parameters, error) in
            if error == nil {
                // 每次由背景進到前景就會回調，故在此多加判斷過濾掉非DeepLink的事件
                // 參考：https://github.com/BranchMetrics/ios-branch-deep-linking/issues/15
                if let parameters = parameters, parameters.count > 5 {
                    SystemManager.setDeepLinkInfo(info: parameters)
                    SystemManager.handleDeepLink()
                }
            }
        })
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // ios10以上 App在背景或是未啟動收到推播時點擊推播觸發
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let extraPayLoad = response.notification.request.content.userInfo["extraPayLoad"] as? [String:Any] {
            if let order = extraPayLoad["order"] as? [String:Any] {
                print("order: \(order)")
                handleReceiveRemoteNotification(userInfo: order)
                // 更新訂單記錄列表
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kShouldReloadOrderRecord), object: nil)
            } else if let infoData = extraPayLoad["infoData"] as? [String:Any] {
                print("infoData: \(infoData)")
                handleReceiveRemoteNotification(userInfo: infoData)
            }
        }
        completionHandler()
    }
    
    // ios10以上 App在前景收到推播時觸發
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 因為在前景收到推播後如果使用者點擊就會進到didReceive response function，所以在此不儲存userInfo
        completionHandler([.sound, .alert])
    }
    
    private func handleReceiveRemoteNotification(userInfo: [String:Any]) {
        UserManager.sharedInstance.remoteNotificationUserInfo = userInfo
        if !(SystemManager.topViewController() is LoginViewController) {
            RemoteNotificationManager.handleRemoteNotification()
        }
    }
}
