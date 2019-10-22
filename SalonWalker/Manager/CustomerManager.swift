//
//  CustomerManager.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/15.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

struct CustomerListModel: Codable {
    struct CustomerListInfo: Codable {
        var mId: Int
        var nickName: String
        var headerImgUrl: String
        
        var select: Bool?
    }
    
    var meta: MetaModel
    var customerList: [CustomerListInfo]?
}

struct CustomerDataModel: Codable {
    var mId: Int
    var nickName: String
    var headerImgUrl: String
    var hairType: Int          // 髮質類型: 1: 細軟, 2: 細硬, 3: 粗軟, 4: 粗硬
    var scalp: Int
}

struct HairStyleModel: Codable {
    var sex: String
    var growth: Int            // 長度
    var style: Int             // 形狀 1:瀏海, 2:側分, 3:中分, 4:鮑伯
}

struct SvcContentModel: Codable {
    var photoImgUrl: [String]?
    var hairStyle: HairStyleModel?
    var svcCategory: [SvcCategoryModel]
}

struct CustomerSvcHistoryModel: Codable {
    struct SvcHistory: Codable {
        var mId: Int
        var moId: Int
        var orderTime: String
        var svcContent: SvcContentModel
    }
    
    var meta: MetaModel
    var svcHistory: [SvcHistory]
}

struct CustomerPayHistoryModel: Codable {
    struct AvgPrices: Codable {
        var one: Int
        var month: Int
        var year: Int
    }
    struct SvcPayHistory: Codable {
        var orderTime: String
        var payTotal: Int
    }
    
    var meta: MetaModel
    var avgPrices: AvgPrices
    var svcPayHistory: [SvcPayHistory]
}

class CustomerManager: NSObject {
    
    /// C001 我的客戶清單
    static func apiGetCustomerList(page: Int,
                                   pMax: Int = 30,
                                   keyword: String?,
                                   success: @escaping (_ response: BaseModel<CustomerListModel>?) -> Void,
                                   failure: @escaping failureClosure) {
        
//        if let data = APIPatternTool.C001.data(using: .utf8) {
//            do {
//                let result = try JSONDecoder().decode(BaseModel<CustomerListModel>.self, from: data)
//                success(result)
//            } catch {
//                print(error)
//            }
//        }
        
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId,"page":page,"pMax":pMax]
            if let keyword = keyword, keyword.count > 0 {
                parameters["keyword"] = keyword
            }
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Customer.getCustomerList, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<CustomerListModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// C002 刪除我的客戶
    static func apiDeleteCustomerList(mId: [Int],
                                      success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                      failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,"mId":mId]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Customer.delCustomerList, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// C003 取得我的客戶個人資料
    static func apiGetCustomerData(mId: Int,
                                   success: @escaping (_ response: BaseModel<CustomerDataModel>?) -> Void,
                                   failure: @escaping failureClosure) {
//        if let data = APIPatternTool.C003.data(using: .utf8) {
//            do {
//                let result = try JSONDecoder().decode(BaseModel<CustomerDataModel>.self, from: data)
//                success(result)
//            } catch {
//                print(error)
//            }
//        }
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,"mId":mId]
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Customer.getCustomerData, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<CustomerDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// C004 編輯我的客戶個人資料
    static func apiSetCustomerData(mId: Int,
                                   hairType: Int,
                                   scalp: Int,
                                   success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                   failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,"mId":mId,"hairType":hairType,"scalp":scalp]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Customer.setCustomerData, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// C005 取得我得客戶需求紀錄
    static func apiGetCustomerSvcHistory(mId: Int,
                                         page: Int,
                                         pMax: Int,
                                         success: @escaping (_ response: BaseModel<CustomerSvcHistoryModel>?) -> Void,
                                         failure: @escaping failureClosure) {
//        if let data = APIPatternTool.C005.data(using: .utf8) {
//            do {
//                let result = try JSONDecoder().decode(BaseModel<CustomerSvcHistoryModel>.self, from: data)
//                success(result)
//            } catch {
//                print(error)
//            }
//        }
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,"mId":mId,"page":page,"pMax":pMax]
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Customer.getCustomerSvcHistory, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<CustomerSvcHistoryModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// O006 取得我的客戶消費記錄
    static func apiGetCustomerPayHistory(mId: Int,
                                         page: Int,
                                         pMax: Int,
                                         success: @escaping (_ response: BaseModel<CustomerPayHistoryModel>?) -> Void,
                                         failure: @escaping failureClosure) {
//        if let data = APIPatternTool.C006.data(using: .utf8) {
//            do {
//                let result = try JSONDecoder().decode(BaseModel<CustomerPayHistoryModel>.self, from: data)
//                success(result)
//            } catch {
//                print(error)
//            }
//        }
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,"mId":mId,"page":page,"pMax":pMax]
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Customer.getCustomerPayHistory, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<CustomerPayHistoryModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
}


