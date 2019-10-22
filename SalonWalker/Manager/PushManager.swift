//
//  PushManager.swift
//  SalonWalker
//
//  Created by Daniel on 2019/1/7.
//  Copyright © 2019年 skywind. All rights reserved.
//

import UIKit

class PushManager: NSObject {
    /// PM003 業主發送推播分享場地給設計師
    static func apiProviderSharePlaces(douId: Int,
                                       success: @escaping (_ response: BaseModel<EmptyModel>?) -> Void,
                                       failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["pouId":ouId,"douId":douId]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.PushMessage.providerSharePlaces, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<EmptyModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// PM004 設計師修改資訊(SH002、O005)後，發送推播通知有窩藏該設計師的消費者
    static func apiDesignerEditInfo(success: ((_ response: BaseModel<EmptyModel>?) -> Void)?,
                                    failure: failureClosure?) {
        if let ouId = UserManager.sharedInstance.ouId {
            APIManager.sendPostRequestWith(parameters: ["douId":ouId], path: ApiUrl.PushMessage.designerEditInfo, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<EmptyModel>.self)
                success?(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
}
