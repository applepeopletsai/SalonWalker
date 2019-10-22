//
//  ReservationManager.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/7.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum ServiceValueType {
    case Price, Time
}

struct DesignerSvcItemsModel: Codable {
    var itemId: String
    var svcCategory: [SvcCategoryModel]?
}

struct RecSvcDate: Codable {
    var svcDate: [String]?
    var svcTime: [String]?
}

struct RefPhotoModel: Codable {
    
    struct RefPhoto: Codable {
        var rpId: Int
        var sex: String
        var photoImgUrl: String
        
        var select: Bool?
    }
    
    var meta: MetaModel
    var refPhoto: [RefPhoto]?
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if var refPhoto = try container.decodeIfPresent([RefPhoto].self, forKey: .refPhoto) {
            for i in 0..<refPhoto.count {
                refPhoto[i].select = false
            }
            self.refPhoto = refPhoto
        }
        if let meta = try container.decodeIfPresent(MetaModel.self, forKey: .meta) {
            self.meta = meta
        } else {
            self.meta = MetaModel(count: 0, page: 0, pMax: 0, totalPage: 0)
        }
    }
}

struct OrderPayModel: Codable {
    var moId: Int?
    var doId: Int?
    var transferUrl: String
}

struct OrderSvcPricesModel: Codable {
    var svcHoursPrices: HoursAndTimesPricesModel?
    var svcTimesPrices: HoursAndTimesPricesModel?
    var svcLongLeasePrices: LongLeasePricesModel?
}

struct SvcPricesModel: Codable {
    struct LongLease: Codable {
        var purchasedItems: [LongLeasePricesModel]?
        var notPurchased: [LongLeasePricesModel]?
    }
    
    var svcHours: SvcHoursAndTimesPriceModel?
    var svcTimes: SvcHoursAndTimesPriceModel?
    var svcLongLease: LongLease?
}

struct RecSeatModel: Codable {
    struct RecSeat: Codable {
        var isRecSeat: Bool
        var recSeatMsg: String
    }
    var svcDate: [String]?
    var recSeat: RecSeat?
}

struct OrderSvcItemsModel: Codable {
    struct Service: Codable {
        var hairStyle: HairStyleModel?
        var oepId: [Int]?
        var svcCategory: [SvcCategoryModel]
    }
    var moId: Int
    var itemId: String
    var mId: Int
    var ouId: Int
    var service: Service
}

struct QRcodeImgUrlModel: Codable {
    var qrCodeImgUrl: String
}

struct ReservationDetailModel {
    var itemId: String?
    var dId: Int?
    var pId: Int?
    var placeName: String?
    var nickName: String?
    var isTop: Bool?
    var headerImgUrl: String?
    var cityName: String?
    var langName: String?
    var orderDate: String?
    var orderTime: String?
    var week: String?
    var deposit: Int?
    var finalPayment: Int?
    var payType: String?
    var svcContent: DesignerSvcItemsModel?
    var hairStyle: HairStyleModel?
    var oepId: [Int]?
    var photoImgUrl: [String]?
    
    var coverArray: [CoverImg]?
    var refPhotoArray: [RefPhotoModel.RefPhoto]?
}

class ReservationManager: NSObject {
    static let shared = ReservationManager()
    var reservationDetailModel: ReservationDetailModel?
    
    /// R001 取得設計師服務定價項目
    static func apiGetSvcItems(mId: Int,
                               dId: Int,
                               success: @escaping (_ response: BaseModel<DesignerSvcItemsModel>?) -> Void,
                               failure: @escaping failureClosure) {
        let parameters: [String:Any] = ["mId":mId,"dId":dId]
        APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Reservation.getSvcItems, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<DesignerSvcItemsModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// R002 計算預約時間(消費者訂單)
    static func apiGetRecSvcDate(dId: Int,
                                 svcTimeTotal: Int,
                                 svcDate: String?,
                                 success: @escaping (_ response: BaseModel<RecSvcDate>?) -> Void,
                                 failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            var parameters: [String:Any] = ["mId":mId,"dId":dId,"svcTimeTotal":svcTimeTotal]
            if let svcDate = svcDate {
                parameters["svcDate"] = svcDate
            }
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Reservation.getRecSvcDate, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<RecSvcDate>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// R003 取得可預約場地列表
    static func apiGetSvcPlace(dId: Int,
                               orderDate: String,
                               startTime: String,
                               svcTimeTotal: Int,
                               page: Int,
                               pMax: Int,
                               placeKeyWord: String?,
                               success: @escaping (_ response: BaseModel<SvcPlaceInfoModel>?) -> Void,
                               failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            var parameters: [String:Any] = ["mId":mId,"dId":dId,"orderDate":orderDate,"startTime":startTime,"svcTimeTotal":svcTimeTotal,"page":page,"pMaxe":pMax]
            if let placeKeyWord = placeKeyWord {
                parameters["placeKeyWord"] = placeKeyWord
            }
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Reservation.getSvcPlace, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<SvcPlaceInfoModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// R004 取得窩客推薦相片
    static func apiGetRefPhoto(sex: String,
                               page: Int,
                               pMax: Int = 100,
                               success: @escaping (_ response: BaseModel<RefPhotoModel>?) -> Void,
                               failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            let parameters: [String:Any] = ["mId":mId,"sex":sex,"page":page,"pMax":pMax]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Reservation.getRefPhoto, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<RefPhotoModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    #if SALONWALKER
    /// R005 確認預約 - 消費者訂單(訂單付款)
    static func apiMemberOrderPayDeposit(dId: Int,
                                         model: ReservationDetailModel,
                                         success: @escaping (_ response: BaseModel<OrderPayModel>?) -> Void,
                                         failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            var parameters: [String:Any] = ["mId":mId,"dId":dId]
            
            if let orderDate = model.orderDate {
                parameters["orderDate"] = orderDate
            }
            if let startTime = model.orderTime {
                parameters["startTime"] = startTime
            }
            if let svcCategory = model.svcContent?.svcCategory {
                parameters["svcTimeTotal"] = ReservationManager.calculateServiceTotalValue(selectCategory: svcCategory, type: .Time)
            }
            if let pId = model.pId {
                parameters["pId"] = pId
            }
            if let deposit = model.deposit {
                parameters["deposit"] = deposit
            }
            if let finalPayment = model.finalPayment {
                parameters["finalPayment"] = finalPayment
            }
            
            var svcItemsJsonData: [String:Any] = ["mId":mId,"ouId":dId]
            if let itemId = model.itemId {
                svcItemsJsonData["itemId"] = itemId
            }

            var serviceDic = [String:Any]()
            if let hairStyle = model.hairStyle {
                serviceDic["hairStyle"] = ["sex":hairStyle.sex,
                                           "growth":hairStyle.growth,
                                           "style":hairStyle.style]
            }
            if let oepId = model.oepId {
               serviceDic["oepId"] = oepId
            }
            if let svcCategory = model.svcContent?.svcCategory {
                var svcCategoryArray = [[String:Any]]()
                for category in svcCategory {
                    if category.select ?? false {
                        svcCategoryArray.append(getSvcCategoryDic(model: category))
                    }
                }
                serviceDic["svcCategory"] = svcCategoryArray
            }
            svcItemsJsonData["service"] = serviceDic
            parameters["svcItemsJsonData"] = svcItemsJsonData
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Reservation.memberOrderPayDeposit, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<OrderPayModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    #endif
    
    /// R006 更改訂單狀態(消費者訂單)
    //  orderStatus：cancel: 取消 / cashPay: 現金付款 / leave: 離開
    static func apiMembersOrderChgStatus(moId: Int,
                                         orderStatus: String,
                                         success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                         failure: @escaping failureClosure) {
        var parameters: [String:Any] = ["moId":moId,"orderStatus":orderStatus]
        if let mId = UserManager.sharedInstance.mId {
            parameters["mId"] = mId
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Reservation.membersOrderChgStatus, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else if let ouId = UserManager.sharedInstance.ouId {
            parameters["ouId"] = ouId
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Reservation.membersOrderChgStatus, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// R007 取得訂單計價方式
    static func apiGetOrderSvcPrices(moId: Int,
                                     success: @escaping (_ response: BaseModel<OrderSvcPricesModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        let parameters: [String:Any] = ["moId":moId]
        APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Reservation.getOrderSvcPrices, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<OrderSvcPricesModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// R008 取得計價方式
    static func apiGetSvcPrices(pId: Int,
                                success: @escaping (_ response: BaseModel<SvcPricesModel>?) -> Void,
                                failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["pId":pId,"ouId":ouId]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Reservation.getSvcPrices, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<SvcPricesModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// R009 計算預約日期 (設計師訂單)
    static func apiGetSvcTime(pId: Int,
                              svcDate: String?,
                              startTime: String?,
                              endTime: String?,
                              model: OrderDetailInfoModel?,
                              success: @escaping (_ response: BaseModel<RecSeatModel>?) -> Void,
                              failure: @escaping failureClosure) {
        
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["pId":pId,"ouId":ouId]
            
            if let svcDate = svcDate {
                parameters["svcDate"] = svcDate
            }
            if let startTime = startTime {
                parameters["startTime"] = startTime
            }
            if let endTime = endTime {
                parameters["endTime"] = endTime
            }
            
            var svcPricesJsonData = [String:Any]()
            svcPricesJsonData["ouId"] = ouId
            
            if let svcHours = model?.svcHoursPrices {
                var svcHoursDic = [String:Any]()
                var dic = [String:Any]()
                dic["weekDay"] = svcHours.weekDay
                dic["prices"] = svcHours.prices
                svcHoursDic["svcHoursPrices"] = dic
                svcPricesJsonData["svcHours"] = svcHoursDic
            }
            if let svcTimes = model?.svcTimesPrices {
                var svcTimesDic = [String:Any]()
                var dic = [String:Any]()
                dic["weekDay"] = svcTimes.weekDay
                dic["prices"] = svcTimes.prices
                svcTimesDic["svcTimesPrices"] = dic
                svcPricesJsonData["svcTimes"] = svcTimesDic
            }
            if let svcLongLease = model?.svcLongLeasePrices {
                if let startDay = svcLongLease.startDay, let endDay = svcLongLease.endDay, let prices = svcLongLease.prices {
                    var svcLongLeaseDic = [String:Any]()
                    var dic = [String:Any]()
                    dic["startDay"] = startDay
                    dic["endDay"] = endDay
                    dic["prices"] = prices
                    svcLongLeaseDic["svcLongLeasePrices"] = dic
                    svcPricesJsonData["svcLongLease"] = svcLongLeaseDic
                }
            }
            parameters["svcPricesJsonData"] = svcPricesJsonData
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Reservation.getSvcTime, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<RecSeatModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// R010 確認預約 - 設計師訂單 - 付款
    static func apiDesignerOrderPayDeposit(moId: Int?,
                                           pId: Int,
                                           orderType: Int,
                                           orderDate: String?,
                                           startTime: String?,
                                           endTime: String?,
                                           deposit: Int?,
                                           finalPayment: Int?,
                                           rent: Int?,
                                           model: OrderDetailInfoModel?,
                                           success: @escaping (_ response: BaseModel<OrderPayModel>?) -> Void,
                                           failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId,"pId":pId,"orderType":orderType]
            
            if let moId = moId {
                parameters["moId"] = moId
            }
            if let orderDate = orderDate {
                parameters["orderDate"] = orderDate
            }
            if let startTime = startTime {
                parameters["startTime"] = startTime
            }
            if let endTime = endTime {
                parameters["endTime"] = endTime
            }
            if let deposit = deposit {
                parameters["deposit"] = deposit
            }
            if let finalPayment = finalPayment {
                parameters["finalPayment"] = finalPayment
            }
            if let rent = rent {
                parameters["rent"] = rent
            }
            
            var svcPricesJsonData = [String:Any]()
            svcPricesJsonData["ouId"] = ouId
            
            if let svcHours = model?.svcHoursPrices {
                var svcHoursDic = [String:Any]()
                var dic = [String:Any]()
                dic["weekDay"] = svcHours.weekDay
                dic["prices"] = svcHours.prices
                svcHoursDic["svcHoursPrices"] = dic
                svcPricesJsonData["svcHours"] = svcHoursDic
            }
            if let svcTimes = model?.svcTimesPrices {
                var svcTimesDic = [String:Any]()
                var dic = [String:Any]()
                dic["weekDay"] = svcTimes.weekDay
                dic["prices"] = svcTimes.prices
                svcTimesDic["svcTimesPrices"] = dic
                svcPricesJsonData["svcTimes"] = svcTimesDic
            }
            if let svcLongLease = model?.svcLongLeasePrices {
                if let startDay = svcLongLease.startDay, let endDay = svcLongLease.endDay, let prices = svcLongLease.prices {
                    var svcLongLeaseDic = [String:Any]()
                    var dic = [String:Any]()
                    dic["startDay"] = startDay
                    dic["endDay"] = endDay
                    dic["prices"] = prices
                    svcLongLeaseDic["svcLongLeasePrices"] = dic
                    svcPricesJsonData["svcLongLease"] = svcLongLeaseDic
                }
            }
            parameters["svcPricesJsonData"] = svcPricesJsonData
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Reservation.designerOrderPayDeposit, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<OrderPayModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// R011 更改訂單狀態 (設計師訂單)
    static func apiDesignerOrderChgStatus(doId: Int,
                                          orderStatus: String,
                                          success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                          failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let ouType = (UserManager.sharedInstance.userIdentity == .designer) ? "Designer" : "Provider"
            let parameters: [String:Any] = ["doId":doId,"ouId":ouId,"ouType":ouType,"orderStatus":orderStatus]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Reservation.designerOrderChgStatus, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        }
    }
    
    /// R012 產生QRcode (場地業者)
    static func apiQRcodeImgUrl(success: @escaping (_ response: BaseModel<QRcodeImgUrlModel>?) -> Void,
                                failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters = ["ouId":ouId]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Reservation.qrCodeImgUrl, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<QRcodeImgUrlModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// R014 簽到/簽退 (設計師/消費者)
    static func apiPunchInAndOut(signClass: String,
                                 moId: Int?,
                                 doId: Int?,
                                 pId: Int?,
                                 signType: Bool,
                                 lat: Double?,
                                 lng: Double?,
                                 success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                 failure: @escaping failureClosure) {
        var parameters: [String:Any] = ["signClass":signClass,"signType":signType]
        if let pId = pId {
            parameters["pId"] = pId
        }
        if let moId = moId {
            parameters["moId"] = moId
        }
        if let doId = doId {
            parameters["doId"] = doId
        }
        if let lat = lat {
            parameters["lat"] = lat
        }
        if let lng = lng {
            parameters["lng"] = lng
        }
        
        if let mId = UserManager.sharedInstance.mId {
            parameters["mId"] = mId
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Reservation.punchInAndOut, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else if let ouId = UserManager.sharedInstance.ouId {
            parameters["ouId"] = ouId
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Reservation.punchInAndOut, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
        
    }
    
    /// R015 取得消費者訂單服務項目
    static func apiGetMembersOrderSvcItems(moId: Int,
                                           success: @escaping (_ response: BaseModel<OrderSvcItemsModel>?) -> Void,
                                           failure: @escaping failureClosure) {
        let parameters = ["moId":moId]
        APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Reservation.getMembersOrderSvcItems, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<OrderSvcItemsModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// R016 編輯消費者訂單服務項目
    static func apiSetMembersOrderSvcItems(model: OrderSvcItemsModel,
                                           success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                           failure: @escaping failureClosure) {
        
        var parameters: [String:Any] = ["moId":model.moId]
        let totalPrice = ReservationManager.calculateServiceTotalValue(selectCategory: model.service.svcCategory, type: .Price)
        parameters["total"] = totalPrice
        
        var svcItemsJsonData: [String:Any] = ["itemId":model.itemId,"mId":model.mId,"ouId":model.ouId]
        
        
        var serviceDic = [String:Any]()
        if let hairStyle = model.service.hairStyle {
            serviceDic["hairStyle"] = ["sex":hairStyle.sex,
                                       "growth":hairStyle.growth,
                                       "style":hairStyle.style]
        }
        if let oepId = model.service.oepId {
            serviceDic["oepId"] = oepId
        }
        
        var svcCategoryArray = [[String:Any]]()
        for category in model.service.svcCategory {
            if category.select ?? false {
                svcCategoryArray.append(getSvcCategoryDic(model: category))
            }
        }
        serviceDic["svcCategory"] = svcCategoryArray
        svcItemsJsonData["service"] = serviceDic
        parameters["svcItemsJsonData"] = svcItemsJsonData
        
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Reservation.setMembersOrderSvcItems, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
            success(result)
        }, failure: failure)

    }
    
    /// R017 編輯設計師訂單計費方案
    static func apiSetDesignerOrderSvcItems(doId: Int,
                                            orderType: Int,
                                            endTime: String,
                                            total: Int,
                                            success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                            failure: @escaping failureClosure) {
        let parameters: [String:Any] = ["doId":doId,"orderType":orderType,"endTime":endTime,"total":total]
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Reservation.setDesignerOrderSvcItems, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// R018 訂單- 付尾款
    static func apiOrderFinalPayment(moId: Int?,
                                     doId: Int?,
                                     success: @escaping (_ response: BaseModel<OrderPayModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        var parameters = [String:Any]()
        if let moId = moId {
            parameters["moId"] = moId
        } else if let doId = doId {
            parameters["doId"] = doId
        }
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Reservation.orderPayFinalPayment, success: { (response) in
        let result = APIManager.decode(response: response, type: BaseModel<OrderPayModel>.self)
        success(result)
        }, failure: failure)
    }
    
    /// 計算消費者在預約設計師中所選取服務的總價與總時間
    static func calculateServiceTotalValue(selectCategory: [SvcCategoryModel], type: ServiceValueType) -> Int {
        var totalValue = 0
        
        for svcCategory in selectCategory {
            if svcCategory.select ?? false {
                if svcCategory.selectionType == .OnlySelect {
                    totalValue += (type == .Price) ? (svcCategory.price ?? 0) : (svcCategory.hours ?? 0)
                } else {
                    if let selectSvcClass = svcCategory.selectSvcClass {
                        for svcClass in selectSvcClass {
                            if let selectItem = svcClass.svcItems {
                                for svcItem in selectItem {
                                    totalValue += (type == .Price) ? (svcItem.price ?? 0) : (svcItem.hours ?? 0)
                                }
                            } else {
                                totalValue += (type == .Price) ? (svcClass.price ?? 0) : (svcClass.hours ?? 0)
                            }
                        }
                    }
                }
            }
        }
        return totalValue
    }
    
    private static func getSvcCategoryDic(model: SvcCategoryModel) -> [String:Any] {
        var categoryDic: [String:Any] = ["name":model.name]
        if let iconUrl = model.iconUrl {
            categoryDic["iconUrl"] = iconUrl
        }
        if let price = model.price {
            categoryDic["price"] = price
        }
        
        if model.selectionType != .OnlySelect, let svcClasses = model.selectSvcClass {
            var svcClassArray = [[String:Any]]()
            for svcClass in svcClasses {
                var svcClassDic: [String:Any] = ["name":svcClass.name]
                if let price = svcClass.price {
                    svcClassDic["price"] = price
                }
                
                if let svcItems = svcClass.svcItems {
                    var svcItemArray = [[String:Any]]()
                    for svcItem in svcItems {
                        var svcItemDic: [String:Any] = ["name":svcItem.name]
                        if let price = svcItem.price {
                            svcItemDic["price"] = price
                        }
                        svcItemArray.append(svcItemDic)
                    }
                    svcClassDic["svcItems"] = svcItemArray
                }
                svcClassArray.append(svcClassDic)
            }
            categoryDic["svcClass"] = svcClassArray
        }
        return categoryDic
    }
    
}
