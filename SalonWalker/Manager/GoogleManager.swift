//
//  GoogleManager.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/1.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import GoogleSignIn

class GoogleManager: NSObject {
    private static let sharedInstance = GoogleManager()
    
    private var userId: String?
    private var userName: String?
    private var email: String?
    private var imageUrl: String?
    private var success: actionClosure?
    private var failure: actionClosure?
    
    override init() {
        super.init()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    static func loginWith(success: actionClosure?, failure: actionClosure?) {
        GoogleManager.sharedInstance.success = success
        GoogleManager.sharedInstance.failure = failure
        GIDSignIn.sharedInstance().signIn()
    }
    
    static func logout() {
        GIDSignIn.sharedInstance().signOut()
    }
    
    static func getUserId() -> String {
        return GoogleManager.sharedInstance.userId ?? ""
    }
    
    static func getUserName() -> String {
        return GoogleManager.sharedInstance.userName ?? ""
    }
    
    static func getEmail() -> String {
        return GoogleManager.sharedInstance.email ?? ""
    }
    
    static func getPictureUrl() -> String? {
        return GoogleManager.sharedInstance.imageUrl
    }
    
//    private static func checkCurrentUser() -> Bool {
//        if GIDSignIn.sharedInstance().currentUser != nil {
//            return true
//        }
//        return false
//    }
}

extension GoogleManager: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print("=== Googl登入失敗，原因：\(error.localizedDescription)")
            GoogleManager.sharedInstance.failure?()
        } else {
            GoogleManager.sharedInstance.userId = user.userID
            GoogleManager.sharedInstance.userName = user.profile.name
            GoogleManager.sharedInstance.email = user.profile.email
            GoogleManager.sharedInstance.imageUrl = user.profile.imageURL(withDimension: 100).absoluteString
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                GoogleManager.sharedInstance.success?()
            })
        }
    }
}

extension GoogleManager: GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        SystemManager.topViewController().present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        SystemManager.topViewController().dismiss(animated: true, completion: nil)
    }
}

