//
//  ProviderServiceManager.swift
//  SalonWalker
//
//  Created by Skywind on 2018/6/7.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

struct HoursAndTimesPricesModel: Codable {
    var weekDay: Int
    var prices: Int
}

struct LongLeasePricesModel: Codable {
    var startDay: String?
    var endDay: String?
    var prices: Int?
}

struct SvcHoursAndTimesPriceModel: Codable {
    var open: Bool?
    var svcHoursPrices: [HoursAndTimesPricesModel]?
    var svcTimesPrices: [HoursAndTimesPricesModel]?
}

struct SvcLongLeasePricesModel: Codable {
    var open: Bool?
    var svcLongLeasePrices: [LongLeasePricesModel]?
}

struct PlaceSvcPricesModel: Codable {
    var itemId: String
    var ouId: Int
    var svcHours: SvcHoursAndTimesPriceModel?
    var svcTimes: SvcHoursAndTimesPriceModel?
    var svcLongLease: SvcLongLeasePricesModel?
}

class ProviderServiceManager: NSObject {
    /// PS001 取得場地業者服務計價 
    static func apiGetPlaceSvcPrices(success: @escaping (_ response: BaseModel<PlaceSvcPricesModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            APIManager.sendGetRequestWith(parameters: ["ouId":ouId], path: ApiUrl.ProviderService.getPlaceSvcPrices, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<PlaceSvcPricesModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// PS002 編輯場地業者服務計價
    static func apiSetPlaceSvcPrices(model: PlaceSvcPricesModel,
                                     success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        
        var dic = [String:Any]()
        dic["itemId"] = model.itemId
        dic["ouId"] = model.ouId
        
        if let svcHours = model.svcHours {
            var svcHoursDic = [String:Any]()
            svcHoursDic["open"] = svcHours.open ?? false
            
            if let svcHoursPrices = svcHours.svcHoursPrices, svcHoursPrices.count > 0 {
                var array = [[String:Any]]()
                for model in svcHoursPrices {
                    array.append(["weekDay":model.weekDay,"prices":model.prices])
                }
                svcHoursDic["svcHoursPrices"] = array
            }
            
            dic["svcHours"] = svcHoursDic
        }
        
        if let svcTimes = model.svcTimes {
            var svcTimesDic = [String:Any]()
            svcTimesDic["open"] = svcTimes.open ?? false
            
            if let svcTimesPrices = svcTimes.svcTimesPrices, svcTimesPrices.count > 0 {
                var array = [[String:Any]]()
                for model in svcTimesPrices {
                    array.append(["weekDay":model.weekDay,"prices":model.prices])
                }
                svcTimesDic["svcTimesPrices"] = array
            }
            
            dic["svcTimes"] = svcTimesDic
        }
        
        if let svcLongLease = model.svcLongLease {
            var svcLongLeaseDic = [String:Any]()
            svcLongLeaseDic["open"] = svcLongLease.open ?? false
            
            if let svcLongLeasePrices = svcLongLease.svcLongLeasePrices, svcLongLeasePrices.count > 0 {
                var array = [[String:Any]]()
                for model in svcLongLeasePrices {
                    if let startDay = model.startDay, let endDay = model.endDay, let prices = model.prices {
                        array.append(["startDay":startDay,"endDay":endDay,"prices":prices])
                    }
                }
                svcLongLeaseDic["svcLongLeasePrices"] = array
            }
            
            dic["svcLongLease"] = svcLongLeaseDic
        }
        
        APIManager.sendPostRequestWith(parameters: ["svcPricesJsonData":dic], path: ApiUrl.ProviderService.setPlaceSvcPrices, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
            success(result)
        }, failure: failure)
    }
    
    // MARK: Method
    static func getWorkTimeModel(_ array: [HoursAndTimesPricesModel]) -> [WorkTimeModel] {
        var samePriceIndexArray: [[Int]] = []
        let priceArray = array.enumerated().map{ $0.element.prices }
        let set = Set(priceArray).sorted()
        for price in set {
            let samePriceIndex = priceArray.enumerated().filter{ $0.element == price }.map{ $0.offset }
            samePriceIndexArray.append(samePriceIndex)
        }
        
        var result = [WorkTimeModel]()
        for samePriceIndex in samePriceIndexArray {
            let weekDay = samePriceIndex.map{ array[$0].weekDay }
            let model = WorkTimeModel(weekIndex: weekDay, from: nil, end: nil, price: array[samePriceIndex.first!].prices)
            result.append(model)
        }
        return result
    }
    
}
