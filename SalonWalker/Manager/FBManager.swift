//
//  FBManager.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/1.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class FBManager: NSObject {
    private static let sharedInstance = FBManager()
    
    private var userId: String?
    private var userName: String?
    private var email: String?
    private var imageUrl: String?
    
    static func loginWith(success: actionClosure?, failure: actionClosure?) {
        if checkAccessToken() {
            FBManager.getFbProfileWith(success: success, failure: failure)
        } else {
            FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: SystemManager.topViewController(), handler: { (result, error) in
                if error != nil {
                    print("FB登入失敗，原因：\(error?.localizedDescription ?? "未知原因")")
                    failure?()
                    return
                }
                FBManager.getFbProfileWith(success: success, failure: failure)
            })
        }
    }
    
    static func logout() {
        FBSDKLoginManager().logOut()
    }
    
    static func getUserId() -> String {
        return FBManager.sharedInstance.userId ?? ""
    }
    
    static func getUserName() -> String {
        return FBManager.sharedInstance.userName ?? ""
    }
    
    static func getEmail() -> String {
        return FBManager.sharedInstance.email ?? ""
    }
    
    static func getPictureUrl() -> String? {
        return FBManager.sharedInstance.imageUrl
    }
   
    static func getFbProfileWith(success: actionClosure?, failure: actionClosure?) {
        // 需要取得的資訊種類
        let parameters = ["fields": "id, first_name, last_name, name, email, picture.type(large), link, birthday"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: {
            connection, result, error -> Void in
            if error != nil {
                print("取得FB資訊失敗，原因：\(error?.localizedDescription ?? "未知原因")" )
                failure?()
                return
            }
            if let dataDic = result as? [String:Any] {
                FBManager.sharedInstance.userId = dataDic["id"] as? String
                FBManager.sharedInstance.userName = dataDic["name"] as? String
                FBManager.sharedInstance.email = dataDic["email"] as? String
                
                if let picture = dataDic["picture"] as? NSDictionary, let data = picture["data"] as? NSDictionary, let url = data["url"] as? String {
                    FBManager.sharedInstance.imageUrl = url
                }
            }
            success?()
        })
    }
    
    private static func checkAccessToken() -> Bool {
        if FBSDKAccessToken.current() != nil {
            return true
        }
        return false
    }
    
}
