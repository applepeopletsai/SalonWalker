//
//  TransactionSettingManager.swift
//  SalonWalker
//
//  Created by Skywind on 2018/6/6.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

struct BankInfoModel: Codable {
    var ouId: Int
    var ouType: String
    var bankCode: String        // 銀行代碼
    var bankName: String        // 銀行名稱
    var bankBranch: String      // 分行代碼
    var bankNum: String         // 分行帳戶
}

struct BankListModel: Codable {
    var bank: [BankModel]
}

struct BankModel: Codable {
    var bankCode: String
    var bankName: String
}

class TransactionSettingManager: NSObject {
    /// TS001 取得交易設定 (設計師 / 業者)
    static func apiGetOperatingTxnSetting(success: @escaping (_ response: BaseModel<BankInfoModel>?) -> Void,
                                          failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String: Any] = ["ouId":ouId,"ouType":OperatingManager.getUserOuType()]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.TransactionSetting.getOperatingTxnSetting, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<BankInfoModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// TS002 設定交易設定 (設計師 / 業者)
    static func apiSetOperatingTxnSetting(bankCode: String,
                                          bankBranch: String?,
                                          bankNum: String,
                                          success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                          failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String: Any] = ["ouId":ouId,"ouType":OperatingManager.getUserOuType(),"bankCode":bankCode,"bankNum":bankNum]
            if let bankBranch = bankBranch {
                parameters["bankBranch"] = bankBranch
            }
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.TransactionSetting.setOperatingTxnSetting, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// TS003 取得銀行代碼 
    static func apiGetBank(success: @escaping (_ response: BaseModel<BankListModel>?) -> Void,
                           failure: @escaping failureClosure) {
       
        APIManager.sendGetRequestWith(parameters: ["":""], path: ApiUrl.TransactionSetting.getBank, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<BankListModel>.self)
            success(result)
        }, failure: failure)
    }
    
}
