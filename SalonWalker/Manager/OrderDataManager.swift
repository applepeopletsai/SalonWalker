//
//  OrderDataManager.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

struct MemberOrderModel: Codable {
    var orderTime: String?
    var moId: Int
    var nickName: String
    var headerImgUrl: String?
    var isTop: Bool?
    var placeName: String?
    var cityName: String?
    var areaName: String?
    var orderStatus: Int
    var orderStatusName: String
}

struct DesignerOrderModel: Codable {
    struct Designer: Codable {
        var nickName: String
        var headerImgUrl: String?
        var isTop: Bool?
        var cityName: String
        var areaName: String
        var orderStatusName: String
    }
    
    struct Provider: Codable {
        var nickName: String
        var headerImgUrl: String?
        var cityName: String
        var areaName: String
        var address: String
        var orderStatusName: String
    }
    
    var doId: Int
    var orderStatus: Int
    var designer: Designer?
    var provider: Provider?
}

struct CalendarModel_Operating: Codable {
    var orderTime: String
    var designerOrder: DesignerOrderModel?
    var memberOrder: MemberOrderModel?
}

struct MemberCalendarModel: Codable {
    struct Calendar: Codable {
        var date: String
        var order: [MemberOrderModel]
    }
    var calendar: [Calendar]?
}

struct OperatingCalendarModel: Codable {
    struct Calendar: Codable {
        var date: String
        var order: [CalendarModel_Operating]
    }
    var calendar: [Calendar]?
}

struct EvaluateStatusModel: Codable {
    struct Evaluation: Codable {
        var point: Int
        var comment: String
    }
    var statusName: String
    var evaluation: Evaluation?
}

struct OrderListModel: Codable {
    
    struct OrderList: Codable {
        var moId: Int?
        var doId: Int?
        var dId: Int?
        var pId: Int?
        var orderNo: String
        var nickName: String
        var headerImgUrl: String?
        var isTop: Bool?
        var cityName: String?
        var areaName: String?
        var address: String?
        var telArea: String?
        var tel: String?
        var customerName: String?
        var langName: String?
        var placeName: String?
        var deposit: Int
        var finalPayment: Int
        var payTime: String         // 訂單訂金支付時間
        var finishTime: String      // 訂單完成時間 (尾款支付)
        var orderStatus: Int
        var orderStatusName: String
        var evaluateStatus: EvaluateStatusModel
    }
    
    var orderList: [OrderList]?
    var meta: MetaModel
}

struct OrderDetailInfoModel: Codable {
    var moId: Int?                          // 消費者
    var doId: Int?                          // 設計師
    var bindMoId: Int?
    var bindDoId: Int?
    var orderNo: String
    var orderType: Int?                     // 訂單類別(OD008)
    var orderTime: String
    var estimateEndTime: String?
    var endTime: String?
    var deposit: Int
    var depositStatusName: String
    var finalPayment: Int
    var finalPaymentStatusName: String
    var paymentTypeName: String
    var orderStatus: Int
    var member: OrderDetailInfo_Member?
    var designer: OrderDetailInfo_Designer?
    var provider: OrderDetailInfo_Provider?
    var svcContent: SvcContentModel?
    var evaluateStatus: EvaluateStatusModel
    var svcHoursPrices: HoursAndTimesPricesModel?
    var svcTimesPrices: HoursAndTimesPricesModel?
    var svcLongLeasePrices: LongLeasePricesModel?
}

struct OrderDetailInfo_Member: Codable {
    var mId: Int
    var nickName: String
    var headerImgUrl: String?
    var langName: String?
    var orderStatus: Int?
    var orderStatusName: String
    var punchInTime: String?
}

struct OrderDetailInfo_Designer: Codable {
    var dId: Int
    var nickName: String
    var headerImgUrl: String?
    var isTop: Bool
    var cityName: String
    var areaName: String
    var langName: String
    var orderStatusName: String
    var punchInTime: String
    var punchOutTime: String
}

struct OrderDetailInfo_Provider: Codable {
    var pId: Int
    var nickName: String
    var headerImgUrl: String?
    var cityName: String
    var areaName: String
    var address: String
    var telArea: String
    var tel: String
    var orderStatusName: String?
}

class OrderDataManager: NSObject {
    
    /// OD001 我的行事曆(消費者)
    static func apiGetMemberCalandar(startDate: String,
                                     endDate: String,
                                     success: @escaping (_ response: BaseModel<MemberCalendarModel>?) -> Void,
                                     failure: @escaping failureClosure) {
//        if let data = APIPatternTool.OD001.data(using: .utf8) {
//            do {
//                let result = try JSONDecoder().decode(BaseModel<MemberCalandarModel>.self, from: data)
//                success(result)
//            } catch {
//                print(error)
//            }
//        }
        if let mId = UserManager.sharedInstance.mId {
            let parameters: [String:Any] = ["mId":mId,"startDate":startDate,"endDate":endDate]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.OrderData.getMemberCalendar, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<MemberCalendarModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// OD002 我的行事曆(設計師/場地業者)
    static func apiGetOperatingCalendar(startDate: String,
                                        endDate: String,
                                        success: @escaping (_ response: BaseModel<OperatingCalendarModel>?) -> Void,
                                        failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let ouType = (UserManager.sharedInstance.userIdentity == .designer) ? "Designer" : "Provider"
            let parameters: [String:Any] = ["ouId":ouId,"ouType":ouType,"startDate":startDate,"endDate":endDate]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.OrderData.getOperatingCalendar, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<OperatingCalendarModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /*
     訂單狀態：
     100 : 已付訂金 - 待回覆
     200 : 已付訂金 - 已確定
     300 : 已退訂金
     400 : 已罰緩
     500 : 已完成
     **/
    /// OD003 消費者訂單記錄列表(消費者訂單記錄)
    static func apiGetMemberOrderList(status: Int,
                                      page: Int,
                                      pMax: Int = 50,
                                      success: @escaping (_ response: BaseModel<OrderListModel>?) -> Void,
                                      failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            let parameters = ["mId":mId,"status":status,"page":page,"pMax":pMax]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.OrderData.getMemberOrderList, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<OrderListModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /*
     訂單狀態：
     100 : 待回覆
     200 : 已收訂金
     300 : 已取消
     500 : 已完成
     **/
    /// OD004 消費者預約訂單記錄列表(設計師查消費者訂單記錄)
    static func apiGetMemberOrderListByD(status: Int,
                                         page: Int,
                                         pMax: Int = 50,
                                         success: @escaping (_ response: BaseModel<OrderListModel>?) -> Void,
                                         failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters = ["ouId":ouId,"status":status,"page":page,"pMax":pMax]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.OrderData.getMemberOrderListByD, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<OrderListModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// OD005  設計師訂單記錄列表(設計師查看場地訂單記錄)
    static func apiGetDesignerOrderList(status: Int,
                                        page: Int,
                                        pMax: Int = 50,
                                        success: @escaping (_ response: BaseModel<OrderListModel>?) -> Void,
                                        failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters = ["ouId":ouId,"status":status,"page":page,"pMax":pMax]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.OrderData.getDesignerOrderList, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<OrderListModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// OD006 設計師訂單記錄列表(場地業者訂單記錄)
    static func apiGetDesignerOrderListByP(status: Int,
                                           page: Int,
                                           pMax: Int = 50,
                                           success: @escaping (_ response: BaseModel<OrderListModel>?) -> Void,
                                           failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters = ["ouId":ouId,"status":status,"page":page,"pMax":pMax]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.OrderData.getDesignerOrderListByP, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<OrderListModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// OD007 消費者訂單詳細
    static func apiGetMemberOrderInfo(moId: Int,
                                      success: @escaping (_ response: BaseModel<OrderDetailInfoModel>?) -> Void,
                                      failure: @escaping failureClosure) {
        APIManager.sendPostRequestWith(parameters: ["moId":moId], path: ApiUrl.OrderData.getMemberOrderInfo, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<OrderDetailInfoModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// OD008 設計師訂單詳細(設計師查看場地預約訂單)
    static func apiGetDesignerOrderInfo(doId: Int,
                                        success: @escaping (_ response: BaseModel<OrderDetailInfoModel>?) -> Void,
                                        failure: @escaping failureClosure) {
        APIManager.sendPostRequestWith(parameters: ["doId":doId], path: ApiUrl.OrderData.getDesignerOrderInfo, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<OrderDetailInfoModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// OD009 消費者給予設計師評價 (消費者訂單)
    static func apiGiveDesignerEvaluate(dId: Int,
                                        moId: Int,
                                        point: Int,
                                        comment: String?,
                                        success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                        failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            var parameters: [String:Any] = ["mId":mId,"moId":moId,"dId":dId,"point":point]
            if let comment = comment {
                parameters["comment"] = comment
            }
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.OrderData.giveDesignerEvaluate, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// OD010 設計師給予場地業者評價 (設計師訂單)
    static func apiGiveProviderEvaluate(pId: Int,
                                        doId: Int,
                                        point: Int,
                                        comment: String?,
                                        success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                        failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId,"doId":doId,"pId":pId,"point":point]
            if let comment = comment {
                parameters["comment"] = comment
            }
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.OrderData.giveProviderEvaluate, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// OD011 給予檢舉 (消費者訂單)
    static func apiGiveMemberOrderReported(moId: Int,
                                           rrId: Int,
                                           content: String?,
                                           success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                           failure: @escaping failureClosure) {
        let rptType = (UserManager.sharedInstance.userIdentity == .consumer) ? "M" : "D"
        var parameters: [String:Any] = ["moId":moId,"rptType":rptType,"rrId":rrId]
        if let content = content {
            parameters["content"] = content
        }
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.OrderData.giveMemberOrderReported, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// OD012 給予檢舉 (設計師訂單)
    static func aoiGiveDesignerOrderReported(doId: Int,
                                             rrId: Int,
                                             content: String?,
                                             success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                             failure: @escaping failureClosure) {
        let rptType = (UserManager.sharedInstance.userIdentity == .designer) ? "D" : "P"
        var parameters: [String:Any] = ["doId":doId,"rptType":rptType,"rrId":rrId]
        if let content = content {
            parameters["content"] = content
        }
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.OrderData.giveDesignerOrderReported, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
            success(result)
        }, failure: failure)
    }
}


