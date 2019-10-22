//
//  OperatingManager.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/30.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Photos

struct HeaderImg: Codable {
    var imgUrl: String?
    var headerImgId: Int?
    var tempImgId: Int?
    var act: String?
}

struct LicenseImg: Codable {
    var licenseImgId: Int?
    var name: String?
    var imgUrl: String?
    var tempImgId: Int?
    var act: String?
    
    var imageLocalIdentifier: String?
}

struct CoverImg: Codable {
    var coverImgId: Int?
    var imgUrl: String?
    var tempImgId: Int?
    var act: String?
    
    var imageLocalIdentifier: String?
}

struct EquipmentModel: Codable {
    var name: String
    var num: Int
    var characterization: String
}

struct WarningDetailModel: Codable {
    var moId: Int?
    var doId: Int?
    var orderNo: String?
    var violationDate: String?
    var eventContent: String?
}

struct DesignerInfoModel: Codable {
    var ouId: Int
    var dId: Int?
    var email: String?
    var internationalPrefix: String
    var phone: String
    var nickName: String
    var realName: String
    var identityNo: String
    var sex: String // m: 男 / f: 女
    var zcId: Int
    var cityName: String?
    var areaName: String?
    var address: String
    var experience: Int
    var position: String
    var characterization: String
    var licenseImg: [LicenseImg]?
    var coverImg: [CoverImg]
    var headerImg: HeaderImg?
    var slId: Int
    var cautionTotal: Int           // 警告次數
    var missTotal: Int              // 放鳥次數
    var cautionDetail: [WarningDetailModel]?
    var missDetail: [WarningDetailModel]?
    var reminder: Bool              // 預約提醒
    var notice: Bool                // 平台活動、公告
    var status: Int
    var penalty: Penalty?
    var pushTotal: Int
}

struct ProviderInfoModel: Codable {
    var ouId: Int
    var pId: Int
    var email: String?
    var nickName: String
    var telArea: String
    var tel: String
    var internationalPrefix: String
    var phone: String
    var uniformNumber: String
    var zcId: Int
    var cityName: String?
    var areaName: String?
    var address: String
    var areaSize: Int
    var characterization: String
    var contactInformation: String
    var equipment: [EquipmentModel]?
    var coverImg: [CoverImg]
    var headerImg: HeaderImg?
    var slId: Int
    var cautionTotal: Int           // 警告次數
    var missTotal: Int              // 放鳥次數
    var cautionDetail: [WarningDetailModel]?
    var missDetail: [WarningDetailModel]?
    var reminder: Bool              // 預約提醒
    var notice: Bool                // 平台活動、公告
    var status: Int
    var penalty: Penalty?
    var pushTotal: Int
}

struct EquipmentItemModel: Codable {
    var eqQuantity: [String]?
    var eqDescription: [String]?
    
    struct Equipment: Codable {
        var name: String
        var permitQuantity: Bool
        var permitCharacterization: Bool
        var selected: Bool
        var count: Int
        var content: String
    }

    var equipment: [Equipment]?
    
    // 轉換成畫面所需的model
    // 參考：https://stackoverflow.com/a/44575580/7103908
    init(from decoder: Decoder) throws {
        self.equipment = []
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let eqQuantity = try container.decodeIfPresent([String].self, forKey: .eqQuantity) {
            for name in eqQuantity {
                self.equipment?.append(Equipment(name: name, permitQuantity: true, permitCharacterization: false, selected: false, count: 0, content: ""))
            }
        }
        if let eqDescription = try container.decodeIfPresent([String].self, forKey: .eqDescription) {
            for name in eqDescription {
                self.equipment?.append(Equipment(name: name, permitQuantity: false, permitCharacterization: true, selected: false, count: 0, content: ""))
            }
        }
    }
}

struct OrderStatusNumModel: Codable {
    var orderStatusNum: Int
}

class OperatingManager: NSObject {
    
    static func getUserOuType() -> String {
        if (UserManager.sharedInstance.userIdentity == .designer) {
            return "Designer"
        } else if (UserManager.sharedInstance.userIdentity == .store)  {
            return "Provider"
        } else {
            return ""
        }
    }
    
    /// O001 設計師/業者登入
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
        
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Operating.login, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<UserModel>.self)
            success(result)
        }, failure: failure)
        
    }
    
    /// O002 設計師/業者註冊
    static func apiRegister(email: String?,
                            password: String?,
                            fbUid: String?,
                            googleUid: String?,
                            nickName: String,
                            tempImgId: String?,
                            success: @escaping (_ response: BaseModel<UserModel>?) -> Void,
                            failure: @escaping failureClosure) {
        
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId,
                                            "ouType":OperatingManager.getUserOuType(),
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
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Operating.register, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UserModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// O003 設計師/業者重設密碼、忘記密碼
    static func apiResetPsd(opsd: String?,
                            psd: String,
                            success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                            failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId,"psd":psd]
            if let opsd = opsd {
                parameters["opsd"] = opsd
            }
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Operating.resetPassword, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// O004 設計師/業者發送手機驗證碼、重新發送驗證碼
    static func apiSetVerify(confirmType: String,
                             internationalPrefix: String,
                             phone: String,
                             success: @escaping (_ response: BaseModel<VerifyModel>?) -> Void,
                             failure: @escaping failureClosure) {
        let parameters = ["confirmType":confirmType,
                          "internationalPrefix":internationalPrefix,
                          "phone":phone]
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Operating.setVerify, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<VerifyModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// O005 設計師填寫個人資料
    static func apiSetDesignerInfo(editType: String, // R: 註冊, E: 編輯
                                   nickName: String,
                                   realName: String,
                                   identityNo: String,
                                   sex: String,
                                   zcId: Int,
                                   address: String?,
                                   experience: Int,
                                   position: String,
                                   characterization: String,
                                   licenseImg: [LicenseImg]?,
                                   coverImg: [CoverImg],
                                   headerImg: HeaderImg?,
                                   success: @escaping (_ response: BaseModel<UserModel>?) -> Void,
                                   failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var coverImgArray = [[String:Any]]()
            for model in coverImg {
                var dic = [String:Any]()
                if let coverImgId = model.coverImgId {
                    dic["coverImgId"] = coverImgId
                }
                if let tempImgId = model.tempImgId {
                    dic["tempImgId"] = tempImgId
                }
                if let act = model.act {
                    dic["act"] = act
                }
                coverImgArray.append(dic)
            }
            
            var parameters: [String:Any] = ["editType":editType,
                                            "ouId":ouId,
                                            "nickName":nickName,
                                            "realName":realName,
                                            "identityNo":identityNo,
                                            "sex":sex,
                                            "zcId":zcId,
                                            "experience":experience,
                                            "position":position,
                                            "characterization":characterization,
                                            "coverImg":coverImgArray]
            if let address = address {
                parameters["address"] = address
            }
            if let licenseImg = licenseImg, licenseImg.count > 0 {
                var array = [[String:Any]]()
                for model in licenseImg {
                    var dic = [String:Any]()
                    dic["licenseImgId"] = model.licenseImgId
                    dic["name"] = model.name
                    if let tempImgId = model.tempImgId {
                        dic["tempImgId"] = tempImgId
                    }
                    if let act = model.act {
                        dic["act"] = act
                    }
                    array.append(dic)
                }
                parameters["licenseImg"] = array
            }
            if let headerImg = headerImg {
                var dic = [String:Any]()
                
                if let tempImgId = headerImg.tempImgId {
                    dic["tempImgId"] = tempImgId
                }
                if let act = headerImg.act {
                    dic["act"] = act
                }
                parameters["headerImg"] = dic
            }
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Operating.setDesignerInfo, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UserModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// O006 業者填寫個人資料
    static func apiSetProviderInfo(editType: String,
                                   nickName: String,
                                   telArea: String,
                                   tel: String,
                                   uniformNumber: String,
                                   zcId: Int,
                                   address: String,
                                   areaSize: Int,
                                   characterization: String,
                                   contactInformation: String,
                                   equipment: [EquipmentModel]?,
                                   coverImg: [CoverImg],
                                   headerImg: HeaderImg?,
                                   success: @escaping (_ response: BaseModel<UserModel>?) -> Void,
                                   failure: @escaping failureClosure) {

        if let ouId = UserManager.sharedInstance.ouId {
            var coverImgArray = [[String:Any]]()
            for model in coverImg {
                var dic = [String:Any]()
                if let coverImgId = model.coverImgId {
                    dic["coverImgId"] = coverImgId
                }
                if let tempImgId = model.tempImgId {
                    dic["tempImgId"] = tempImgId
                }
                if let act = model.act {
                    dic["act"] = act
                }
                coverImgArray.append(dic)
            }
            
            var parameters: [String:Any] = ["editType":editType,
                                            "ouId":ouId,
                                            "nickName":nickName,
                                            "telArea":telArea,
                                            "tel":tel,
                                            "uniformNumber":uniformNumber,
                                            "zcId":zcId,
                                            "address":address,
                                            "areaSize":areaSize,
                                            "characterization":characterization,
                                            "contactInformation":contactInformation,
                                            "coverImg":coverImgArray]
            
            if let equipment = equipment {
                var array: [[String:Any]] = []
                for model in equipment {
                    array.append(["name":model.name,
                                  "num":model.num,
                                  "characterization":model.characterization])
                }
                
                parameters["equipment"] = array
            }
            
            if let headerImg = headerImg {
                var dic = [String:Any]()
                
                if let tempImgId = headerImg.tempImgId {
                    dic["tempImgId"] = tempImgId
                }
                if let act = headerImg.act {
                    dic["act"] = act
                }
                parameters["headerImg"] = dic
            }
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Operating.setProviderInfo, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UserModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// O007 取得設計師個人資料
    static func apiGetDesignerInfo(success: @escaping (_ response: BaseModel<DesignerInfoModel>?) -> Void,
                                   failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            APIManager.sendPostRequestWith(parameters: ["ouId":ouId], path: ApiUrl.Operating.getDesignerInfo, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<DesignerInfoModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// O008 取得業者場地資料
    static func apiGetProviderInfo(success: @escaping (_ response: BaseModel<ProviderInfoModel>?) -> Void,
                                   failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            APIManager.sendPostRequestWith(parameters: ["ouId":ouId], path: ApiUrl.Operating.getProviderInfo, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<ProviderInfoModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// O009 取得業者設備項目
    static func apiGetEquipment(success: @escaping (_ response: BaseModel<EquipmentItemModel>?) -> Void,
                                failure: @escaping failureClosure) {
        
        APIManager.sendGetRequestWith(parameters: ["":""], path: ApiUrl.Operating.getEquipment, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<EquipmentItemModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// O010 驗證 設計師/業者 註冊信箱/fb/google重複性
    static func apiVerifyOperatingAccount(email: String?,
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
        
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Operating.verifyOperatingAccount, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<EmptyModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// O011 編輯 設計師 / 業者 帳號資訊
    static func apiSetOperatingData(nickName: String,
                                    headerImg: Int?,
                                    success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                    failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId,"ouType":OperatingManager.getUserOuType(),"nickName":nickName]
            if let headerImg = headerImg {
                parameters["headerImg"] = headerImg
            }
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Operating.setOperatingData, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// O013 編輯 設計師/業者 設定資訊
    static func apiSetOperatingSetting(reminder: Bool,
                                       notice: Bool,
                                       success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                       failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,"reminder":reminder,"notice":notice,"ouType":OperatingManager.getUserOuType()]
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Operating.setOperatingSetting, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    ///O014 編輯 設計師 / 業者 語系設定
    static func apiSetOperatingLangSetting(slId: Int,
                                           success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                           failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,"ouType":OperatingManager.getUserOuType(),"slId":slId]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Operating.setOperatingLangSetting, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// O015 更改 設計師 / 業者 手機號碼
    static func apiSetOperatingPhone(internationalPrefix: String,
                                     phone: String,
                                     success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String: Any] = ["ouId":ouId,"ouType":OperatingManager.getUserOuType(),"internationalPrefix":internationalPrefix,"phone":phone]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Operating.setOperatingPhone, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// O017 設計師 / 業者 更改手機 - 發送手機驗證碼
    static func apiSetChgPhoneVerify(internationalPrefix: String,
                                     phone: String,
                                     success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,"ouType":OperatingManager.getUserOuType(),"internationalPrefix":internationalPrefix,"phone":phone]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Operating.setChgPhoneVerify, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// O018 設計師/業者 驗證 手機驗證碼
    static func apiVerifyNum(num: String,
                             success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                             failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String : Any] = ["ouId":ouId,"num":num]
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Operating.verifyNum, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// O019 取得設計師/業者推播通知列表
    static func apiGetPushList(page: Int = 1,
                               pMax: Int = 30,
                               success: @escaping (_ response: BaseModel<PushListModel>?) -> Void,
                               failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            
            let parameters: [String : Any] = ["ouId":ouId,"page":page,"pMax":pMax]
            
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Operating.getPushList, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<PushListModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// O020 取得設計師訂單未回覆小紅點數量
    static func apiGetOrderStatusNum(success: @escaping (_ response: BaseModel<OrderStatusNumModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            APIManager.sendPostRequestWith(parameters: ["ouId":ouId], path: ApiUrl.Operating.getOrderStatusNum, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<OrderStatusNumModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// O021 更改設計師/業者推播通知狀態
    static func apiPushListChgStatus(act: Int,
                                     pushId: Int?,
                                     pushType: String?,
                                     success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String : Any] = ["ouId":ouId,"act":act]
            if let pushId = pushId {
                parameters["pushId"] = pushId
            }
            if let pushType = pushType {
                parameters["pushType"] = pushType
            }
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Operating.pushListChgStatus, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// O022 設計師/業者登出
    static func apiLogut(success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                         failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String : Any] = ["ouId":ouId]
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Operating.logout, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
}
