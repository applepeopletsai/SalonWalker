//
//  DetailManager.swift
//  SalonWalker
//
//  Created by Skywind on 2018/6/13.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

struct WorksModel: Codable {
    // 設計師
    var dwpId: Int?
    var worksImgUrl: String?
    var customerImgUrl: String?
    
    // 場地
    var pppId: Int?
    var placeImgUrl: String?
}

struct DesignerDetailModel: Codable {
    var ouId: Int
    var dId: Int
    var isRes: Bool
    var isTop: Bool
    var isFav: Bool
    var nickName: String
    var cityName: String
    var areaName: String
    var experience: Int
    var position: String
    var characterization: String
    var langName: String
    var evaluationAve: Double
    var evaluationTotal: Int
    var favTotal: Int
    var headerImgUrl: String?
    var licenseImg: [LicenseImg]?
    var coverImg: [CoverImg]
    var cautionTotal: Int
    var missTotal: Int
    var svcPlace: [SvcPlaceModel]?
    var paymentType: [String]?
    var svcCategory: [SvcCategoryModel]?
    var works: [WorksModel]?
    var customer: [WorksModel]?
    var openHour: [OpenHourModel]?
}

struct ProviderDetailModel: Codable {
    var ouId: Int
    var pId: Int
    var isRes: Bool                         //是否可預約
    var isFav: Bool
    var nickName: String
    var cityName: String
    var areaName: String
    var address: String
    var telArea: String
    var tel: String
    var uniformNumber: String               // 統編
    var characterization: String
    var contactInformation: String          // 交通簡介
    var lat: Double
    var lng: Double
    var evaluationAve: Double
    var evaluationTotal: Int
    var favTotal: Int
    var cautionTotal: Int
    var missTotal: Int
    var svcHoursPrices: DayPricesModel?     // 小時計價
    var svcTimesPrices: DayPricesModel?     // 次數計價
    var svcLeasePrices: LeasePricesModel?   // 長租計價
    var headerImgUrl: String?
    var coverImg: [CoverImg]
    var equipment: [EquipmentModel]?
    var works: [WorksModel]?
    var openHour: [OpenHourModel]?
}

struct EvaluateDetailModel: Codable {
    struct List: Codable {
        var name: String
        var point: Int
        var comment: String
        var headerImgUrl: String
    }
    
    var ouId: Int
    var ouType: String
    var evaluationAve: Double
    var evaluationTotal: Int
    var fivePointPct: Int
    var fourPointPct: Int
    var threePointPct: Int
    var twoPointPct: Int
    var onePointPct: Int
    var evaluationList: [List]?
}

class DetailManager: NSObject {
    
    /// D001 設計師 詳細資訊
    static func apiGetDesignerDetail(dId: Int,
                                     success: @escaping(_ response: BaseModel<DesignerDetailModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        
        var parameters: [String:Any] = ["dId":dId]
        if SystemManager.getAppIdentity() == .SalonWalker {
            parameters["mId"] = UserManager.sharedInstance.mId ?? 0
        } else {
            if let ouId = UserManager.sharedInstance.ouId {
                parameters["ouId"] = ouId
                parameters["ouType"] = OperatingManager.getUserOuType()
            } else {
                SystemManager.showErrorAlert(backToLoginVC: true)
                return
            }
        }
//        if let mId = UserManager.sharedInstance.mId {
//           parameters["mId"] = mId
//        } else if let ouId = UserManager.sharedInstance.ouId {
//            parameters["ouId"] = ouId
//            parameters["ouType"] = OperatingManager.getUserOuType()
//        }
        
        APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Detail.getDesignerDetail, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<DesignerDetailModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// D002 場地業者 詳細資訊
    static func apiGetProviderDetail(pId: Int,
                                     success: @escaping(_ response: BaseModel<ProviderDetailModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        var parameters: [String:Any] = ["pId":pId]
        if SystemManager.getAppIdentity() == .SalonWalker {
            parameters["mId"] = UserManager.sharedInstance.mId ?? 0
        } else {
            if let ouId = UserManager.sharedInstance.ouId {
                parameters["ouId"] = ouId
                parameters["ouType"] = OperatingManager.getUserOuType()
            } else {
                SystemManager.showErrorAlert(backToLoginVC: true)
                return
            }
        }
//        if UserManager.sharedInstance.mId == nil &&
//            UserManager.sharedInstance.ouId == nil {
//            SystemManager.showErrorAlert(backToLoginVC: true)
//        } else {
//            var parameters: [String:Any] = ["pId":pId]
            
//            if let mId = UserManager.sharedInstance.mId {
//                parameters["mId"] = mId
//            }
//            if let ouId = UserManager.sharedInstance.ouId {
//                parameters["ouId"] = ouId
//                parameters["ouType"] = OperatingManager.getUserOuType()
//            }
        
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Detail.getProviderDetail, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<ProviderDetailModel>.self)
                success(result)
            }, failure: failure)
//        }
    }
    
    /// D003 評價詳細資訊
    static func apiGetEvaluateDetail(dId: Int?,
                                     pId: Int?,
                                     success: @escaping(_ response: BaseModel<EvaluateDetailModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        var parameters = [String: Int]()
        if let dId = dId {
            parameters["dId"] = dId
        }
        if let pId = pId {
            parameters["pId"] = pId
        }
        
        APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Detail.getEvaluateDetail, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<EvaluateDetailModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// D004 設計師詳細頁檢舉
    static func apiGiveDesignerReported(dId: Int,
                                        content: String,
                                        success: @escaping(_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                        failure: @escaping failureClosure) {
        if UserManager.sharedInstance.mId == nil &&
            UserManager.sharedInstance.ouId == nil {
            SystemManager.showErrorAlert()
        } else {
            var parameters: [String: Any] = ["dId":dId,"content":content]
            if let mId = UserManager.sharedInstance.mId {
                parameters["mId"] = mId
            }
            if let ouId = UserManager.sharedInstance.ouId {
                parameters["ouId"] = ouId
                parameters["ouType"] = OperatingManager.getUserOuType()
            }
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Detail.giveDesignerReported, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        }
    }
    
    /// D005 場地詳細頁檢舉
    static func apiGiveProviderReported(pId: Int,
                                        content: String,
                                        success: @escaping(_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                        failure: @escaping failureClosure) {
        if UserManager.sharedInstance.mId == nil &&
            UserManager.sharedInstance.ouId == nil {
            SystemManager.showErrorAlert()
        } else {
            var parameters: [String: Any] = ["pId":pId,"content":content]
            if let mId = UserManager.sharedInstance.mId {
                parameters["mId"] = mId
            }
            if let ouId = UserManager.sharedInstance.ouId {
                parameters["ouId"] = ouId
                parameters["ouType"] = OperatingManager.getUserOuType()
            }
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Detail.giveProviderReported, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        }
    }
    
    // MARK: Method
    static func getPriceStringWith(svcHoursPrices: DayPricesModel?, svcTimesPrices: DayPricesModel?, svcLeasePrices: LeasePricesModel?, type: String) -> NSMutableAttributedString {
        var workdayItem: String = ""
        var holidayItem: String = ""
        var workdayPrice: Int = 0
        var holidayPrice: Int = 0
        //顯示優先順序: 小時 > 次數 > 長租
        if let svcHoursPrices = svcHoursPrices {
            workdayPrice = svcHoursPrices.workdayPrices
            holidayPrice = svcHoursPrices.holidayPrices
            workdayItem = LocalizedString("Lang_HM_003")
            holidayItem = LocalizedString("Lang_HM_004")
        } else if let svcTimesPrices = svcTimesPrices {
            workdayPrice = svcTimesPrices.workdayPrices
            holidayPrice = svcTimesPrices.holidayPrices
            workdayItem = LocalizedString("Lang_HM_005")
            holidayItem = LocalizedString("Lang_HM_006")
        } else if let svcLeasePrices = svcLeasePrices {
            workdayPrice = svcLeasePrices.prices
            workdayItem = LocalizedString("Lang_HM_007")
        }
        
        let priceAttribute = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),
                              NSAttributedString.Key.foregroundColor : color_2F10A0]
        let itemAttribute = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 10),
                             NSAttributedString.Key.foregroundColor : (type == "HomePage") ? color_2F10A0 : color_595968]
        let combinAttrString = NSMutableAttributedString()
        if workdayPrice != 0 {
            let attrWeekdayPrice = NSAttributedString(string: "$\(workdayPrice) ", attributes: priceAttribute)
            let attrWeekdayItem = NSAttributedString(string: workdayItem, attributes: itemAttribute)
            combinAttrString.append(attrWeekdayPrice)
            combinAttrString.append(attrWeekdayItem)
            if type == "HomePage" && holidayPrice != 0 {
                let attrChangeLine = NSAttributedString(string: "\n", attributes: priceAttribute)
                combinAttrString.append(attrChangeLine)
            }
        }
        if holidayPrice != 0 {
            let attrHolidayPrice = NSAttributedString(string: (type == "HomePage") ? "$\(holidayPrice) " : " $\(holidayPrice) ", attributes: priceAttribute)
            let attrHolidayItem = NSAttributedString(string: holidayItem, attributes: itemAttribute)
            combinAttrString.append(attrHolidayPrice)
            combinAttrString.append(attrHolidayItem)
        }
        return combinAttrString
    }
    
    static func transferToWorkTimeArrayForChart(_ openHour: [OpenHourModel]) -> [[OpenHourModel]] {
        var result = [[OpenHourModel]]()
        var sameWeekDayIndexArray = [[Int]]()
        let weekDayArray = openHour.enumerated().map{ $0.element.weekDay }
        let set = Set(weekDayArray).sorted()
        for week in set {
            let sameWeekDayIndex = weekDayArray.enumerated().filter{ $0.element == week }.map{ $0.offset }
            sameWeekDayIndexArray.append(sameWeekDayIndex)
        }
        
        for indexArray in sameWeekDayIndexArray {
            if indexArray.count > 1 {
                var weekArray = [OpenHourModel]()
                for index in indexArray {
                    let weekDay = openHour[index].weekDay
                    let from = openHour[index].from
                    let end = openHour[index].end
                    weekArray.append(OpenHourModel(weekDay: weekDay, from: from, end: end))
                }
                result.append(weekArray)
            } else {
                result.append([OpenHourModel(weekDay: openHour[indexArray.first!].weekDay, from: openHour[indexArray.first!].from, end: openHour[indexArray.first!].end)])
            }
        }
        
        if set.count < 7 {
            let totalWeekDay = stride(from: 0, to: 7, by: 1)
            let shouldAddWeekDayIndex = totalWeekDay.enumerated().filter{!set.contains($0.element)}.map{$0.element}
            for i in shouldAddWeekDayIndex {
                result.insert([OpenHourModel(weekDay: i, from: "00:00", end: "00:00")], at: i)
            }
        }
        return result
    }
}
