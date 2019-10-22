//
//  MemberManager.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

struct VerifyModel: Codable {
    var ouId: Int?
    var mId: Int?
    var smsAmount: Int
    var msg: String
    var actTime: String
}

struct MemberInfoModel: Codable {
    var mId: Int
    var email: String?
    var internationalPrefix: String
    var phone: String
    var nickName: String
    var headerImgUrl: String?
    var cautionTotal: Int           // 警告次數
    var missTotal: Int              // 放鳥次數
    var cautionDetail: [WarningDetailModel]?
    var missDetail: [WarningDetailModel]?
    var slId: Int
    var reminder: Bool              // 預約提醒
    var notice: Bool                // 平台活動、公告
    var status: Int
    var penalty: Penalty?
    var pushTotal: Int
}

class MemberManager: NSObject {
    
    /// M001 消費者登入
    static func apiLogin(email: String?,
                         password: String?,
                         fbUid: String?,
                         googleUid: String?,
                         success: @escaping (_ response: BaseModel<UserModel>?) -> Void,
                         failure: @escaping failureClosure) {
        var parameters = ["device":"ios",
                          "pushToken":UserManager.getPushToken()]
        
        if let email = email, let password = password {
            parameters["email"] = email
            parameters["psd"] = password
        }
        
        if let fbUid = fbUid {
            parameters["fbUid"] = fbUid
        }
        
        if let googleUid = googleUid {
            parameters["googleUid"] = googleUid
        }
        
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Member.login, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<UserModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// M002 消費者註冊
    static func apiRegister(email: String?,
                            password: String?,
                            fbUid: String?,
                            googleUid: String?,
                            nickName: String,
                            tempImgId: String?,
                            success: @escaping (_ response: BaseModel<UserModel>?) -> Void,
                            failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            var parameters: [String:Any] = ["mId":mId,
                                            "nickName":nickName,
                                            "device":"ios",
                                            "pushToken":UserManager.getPushToken()]
            
            if let email = email, let password = password {
                parameters["email"] = email
                parameters["psd"] = password
            }
            
            if let fbUid = fbUid {
                parameters["fbUid"] = fbUid
            }
            
            if let googleUid = googleUid {
                parameters["googleUid"] = googleUid
            }
            
            if let tempImgId = tempImgId {
                parameters["tempImgId"] = tempImgId
            }
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Member.register, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UserModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// M003 消費者重設密碼、忘記密碼
    static func apiResetPsd(opsd: String?,
                            psd: String,
                            success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                            failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            var parameters: [String:Any] = ["mId":mId,"psd":psd]
            if let opsd = opsd {
                parameters["opsd"] = opsd
            }
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Member.resetPassword, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// M004 消費者 發送手機驗證碼、重新發送驗證碼
    static func apiSetVerify(confirmType: String,
                             internationalPrefix: String,
                             phone: String,
                             success: @escaping (_ response: BaseModel<VerifyModel>?) -> Void,
                             failure: @escaping failureClosure) {
        let parameters = ["confirmType":confirmType,
                          "internationalPrefix":internationalPrefix,
                          "phone":phone]
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Member.setVerify, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<VerifyModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// M005 取得消費者帳號資訊
    static func apiGetMemberInfo(success: @escaping (_ response: BaseModel<MemberInfoModel>?) -> Void,
                                 failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            let parameters = ["mId":mId]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Member.getMemberInfo, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<MemberInfoModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// M006 驗證消費者註冊信箱/fb/google重複性
    static func apiVerifyMemberAccount(email: String?,
                                       fbUid: String?,
                                       googleUid: String?,
                                       success: @escaping (_ response: BaseModel<EmptyModel>?) -> Void,
                                       failure: @escaping failureClosure) {
        var parameters = [String:String]()
        
        if let email = email {
            parameters["email"] = email
        }
        if let fbUid = fbUid {
            parameters["fbUid"] = fbUid
        }
        if let googleUid = googleUid {
            parameters["googleUid"] = googleUid
        }
        
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Member.verifyMemberAccount, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<EmptyModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// M007 編輯消費者帳號資訊
    static func apiSetMemberInfo(nickName: String,
                                 headerImg: Int?,
                                 success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                 failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            var parameters: [String : Any] = ["mId":mId,"nickName":nickName]
            if let headerImg = headerImg {
                parameters["headerImg"] = headerImg
            }
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Member.setMemberInfo, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// M009 編輯消費者設定資訊
    static func apiSetMemberSetting(reminder: Bool,
                                    notice: Bool,
                                    success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                    failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            let parameters: [String:Any] = ["mId":mId,"reminder":reminder,"notice":notice]
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Member.setMemberSetting, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// M010 編輯消費者語系設定
    static func apiSetMemberLangSetting(slId: Int,
                                        success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                        failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            let parameters: [String : Any] = ["mId":mId,"slId":slId]
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Member.setMemberLangSetting, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// M011 更改消費者手機號碼
    static func apiSetMemberPhone(internationalPrefix: String,
                                  phone: String,
                                  success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                  failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            let parameters: [String : Any] = ["mId":mId,"internationalPrefix":internationalPrefix,"phone":phone]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Member.setMemberPhone, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// M012 消費者 更改手機 - 發送手機驗證碼
    static func apiSetChgPhoneVerify(internationalPrefix: String,
                                     phone: String,
                                     success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            let parameters: [String : Any] = ["mId":mId,"internationalPrefix":internationalPrefix,"phone":phone]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Member.setChgPhoneVerify, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// M013 消費者 驗證 手機驗證碼
    static func apiVerifyNum(num: String,
                             success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                             failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
           
            let parameters: [String : Any] = ["mId":mId,"num":num]
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Member.verifyNum, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// M014 取得消費者推播通知列表
    static func apiGetPushList(page: Int = 1,
                               pMax: Int = 30,
                               success: @escaping (_ response: BaseModel<PushListModel>?) -> Void,
                               failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            
            let parameters: [String : Any] = ["mId":mId,"page":page,"pMax":pMax]
            
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Member.getPushList, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<PushListModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// M015 更改消費者推播通知狀態
    static func apiPushListChgStatus(act: Int,
                                     pushId: Int?,
                                     pushType: String?,
                                     success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            var parameters: [String : Any] = ["mId":mId,"act":act]
            if let pushId = pushId {
                parameters["pushId"] = pushId
            }
            if let pushType = pushType {
                parameters["pushType"] = pushType
            }
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Member.pushListChgStatus, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// M016 消費者登出
    static func apiLogut(success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                         failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            let parameters: [String : Any] = ["mId":mId]
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Member.logout, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
}



