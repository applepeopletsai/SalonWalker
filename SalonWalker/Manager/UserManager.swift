//
//  UserManager.swift
//  SalonWalker
//
//  Created by skywind on 2018/3/6.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum UserIdentity: Int {
    case consumer = 0
    case store
    case designer
}

enum AccountStatus: Int {
    // 未註冊,啟用,暫停使用,永久停權,待上架,刪除
    case nonRegister = 0         // 未註冊
    case enable = 1              // 啟用
    case suspend_temporary = 2   // 暫停使用
    case suspend_permanent = 3   // 永久停權
    case registerNotFinish = 4   // 註冊未完成
    case reviewing = 5           // 審核中
    case waitForMarket = 6       // 待上架
    case delete = 9              // 刪除
}

struct Penalty: Codable {
    var startTime: String
    var endTime: String
    var title: String
    var msg: String
}

struct UserModel: Codable {
    var mId: Int?
    var ouId: Int?
    var ouType: String?
    var nickName: String?
    var status: Int
    var msg: String?
    var userToken: String?
    var penalty: Penalty?
}

struct UpdateUserDataModel: Codable {
    var mId: Int?
    var ouId: Int?
    var ouType: String?
    var pId: Int?
    var dId: Int?
    var moId: Int?
    var doId: Int?
    var msg: String?
    var smsAmount: Int?
    var actTime: String?
}

struct PushListModel: Codable {
    
    struct PushDetailModel: Codable, Equatable {
        static func == (lhs: PushDetailModel, rhs: PushDetailModel) -> Bool {
            // 後台的推播通知列表有兩張表，所以有可能會有pushId相同的情況
            return lhs.pushId == rhs.pushId && lhs.pushType == rhs.pushType
        }
        
        var pushId: Int
        var pushType: String
        var pushStatus: Int     // 讀取狀態，0:未讀取、1:已讀取
        var title: String
        var content: String
        var sendTime: String
    }
    
    var meta: MetaModel
    var pushList: [PushDetailModel]?
}

private let prefixKey = (SystemManager.getAppIdentity() == .SalonWalker) ? "SalonWalker" : "SalonMaker"

class UserManager: NSObject {
    static let sharedInstance = UserManager()
    
    var mId: Int?
    var ouId: Int?
    var nickName: String?
    var email: String?
    var password: String?
    var fbUid: String?
    var googleUid: String?
    var penalty: Penalty?
    var accountStatus: AccountStatus?
    var userIdentity: UserIdentity?
    var loginType: LoginType = .general
    var svcClause: [String]?
    var remoteNotificationUserInfo: [String:Any]?
    
    /* 在登入成功後存取使用者資料 **/
    static func saveUserData() {
        if let email = UserManager.sharedInstance.email {
            _ = KeychainManager.saveData(data: email, withIdentifier: prefixKey + "email")
        }
        if let password = UserManager.sharedInstance.password {
            _ = KeychainManager.saveData(data: password, withIdentifier: prefixKey + "password")
        }
        if let fbUid = UserManager.sharedInstance.fbUid {
            _ = KeychainManager.saveData(data: fbUid, withIdentifier: prefixKey + "fbUid")
        }
        if let googleUid = UserManager.sharedInstance.googleUid {
            _ = KeychainManager.saveData(data: googleUid, withIdentifier: prefixKey + "googleUid")
        }
        saveLastLoginType()
    }
    
    static func isLoginSalonWalker() -> Bool {
        return UserManager.sharedInstance.mId != nil
    }
    
    // MARK: Set
    static func saveLastLoginType() {
        UserDefaults.standard.set(UserManager.sharedInstance.loginType.rawValue, forKey: prefixKey + "loginType")
    }
    
    static func saveFirst(_ first: Bool) {
        UserDefaults.standard.set(first, forKey: prefixKey + "First")
        UserDefaults.standard.synchronize()
    }
    
    static func saveUserToken(_ userToken: String) {
        UserDefaults.standard.set(userToken, forKey: prefixKey + "UserToken")
        UserDefaults.standard.synchronize()
    }
    
    static func savePushToken(_ pushToken: String) {
        UserDefaults.standard.set(pushToken, forKey: prefixKey + "PushToken")
        UserDefaults.standard.synchronize()
    }
    
    /// GPS自動偵測
    static func saveGPSAutoDetect(_ GPSAutoDetect: Bool) {
        UserDefaults.standard.set(GPSAutoDetect, forKey: prefixKey + "GPSAutoDetect")
        UserDefaults.standard.synchronize()
    }
    
    /// 瀏覽記錄
    static func saveBrowsingRecord(_ browsingRecord: Bool) {
        UserDefaults.standard.set(browsingRecord, forKey: prefixKey + "BrowsingRecord")
        UserDefaults.standard.synchronize()
    }
    
    // 消費者 理髮服務 全站排行與附近 篩選中的近期搜尋
    static func saveRecentSearch(_ recentSearch: CityCodeModel.CityModel) {
        var array: [CityCodeModel.CityModel] = []
        if let recentArray = UserManager.getRecentSearches() {
            array = recentArray
        }
        array.insert(recentSearch, at: 0)
        
        // 只記錄10筆資料
        if array.count > 10 {
            array.removeLast()
        }
        
        if let encodeArray = try? PropertyListEncoder().encode(array) {
            UserDefaults.standard.set(encodeArray, forKey: prefixKey + "RecentSearches")
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: Get
    static func getLastLoginType() -> LoginType? {
        if let typeString = UserDefaults.standard.object(forKey: prefixKey + "loginType") as? String, let type = LoginType(rawValue: typeString) {
            return type
        }
        return nil
    }
    
    static func getFirst() -> Bool {
        let first = UserDefaults.standard.object(forKey: prefixKey + "First") as? Bool
        return first ?? true
    }
    
    static func getUserToken() -> String {
        let userToken = UserDefaults.standard.object(forKey: prefixKey + "UserToken") as? String
        return userToken ?? ""
    }
    
    static func getPushToken() -> String {
        let pushToken = UserDefaults.standard.object(forKey: prefixKey + "PushToken") as? String
        return pushToken ?? ""
    }
    
    static func getEmail() -> String? {
        if let email = KeychainManager.readData(identifier: prefixKey + "email") as? String {
            return email
        }
        return nil
    }
    
    static func getPassword() -> String? {
        if let password = KeychainManager.readData(identifier: prefixKey + "password") as? String {
            return password
        }
        return nil
    }
    
    static func getFbUid() -> String? {
        if let fbUid = KeychainManager.readData(identifier: prefixKey + "fbUid") as? String {
            return fbUid
        }
        return nil
    }
    
    static func getGoogleUid() -> String? {
        if let googleUid = KeychainManager.readData(identifier: prefixKey + "googleUid") as? String {
            return googleUid
        }
        return nil
    }
    
    static func getRecentSearches() -> [CityCodeModel.CityModel]? {
        if let data = UserDefaults.standard.object(forKey: prefixKey + "RecentSearches") as? Data {
            if let decodeArray = try? PropertyListDecoder().decode([CityCodeModel.CityModel].self, from: data) {
                return decodeArray
            }
        }
        return nil
    }
    
    /// GPS自動偵測
    static func getGPSAutoDetect() -> Bool {
        let GPSAutoDetect = UserDefaults.standard.object(forKey: prefixKey + "GPSAutoDetect") as? Bool
        return GPSAutoDetect ?? true
    }
    
    /// 瀏覽記錄
    static func getBrowsingRecord() -> Bool {
        let browsingRecord = UserDefaults.standard.object(forKey: prefixKey + "BrowsingRecord") as? Bool
        return browsingRecord ?? true
    }
    
    // MARK: Delete
    static func deleteRecentSearches() {
        UserDefaults.standard.removeObject(forKey: prefixKey + "RecentSearches")
        UserDefaults.standard.synchronize()
    }
    
    static func deleteLastLoginType() {
        UserDefaults.standard.removeObject(forKey: prefixKey + "loginType")
        UserDefaults.standard.synchronize()
    }
    
    static func deleteUserToken() {
        UserDefaults.standard.removeObject(forKey: prefixKey + "UserToken")
        UserDefaults.standard.synchronize()
    }
}
