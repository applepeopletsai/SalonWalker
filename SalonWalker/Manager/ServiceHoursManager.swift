//
//  ServiceHoursManager.swift
//  SalonWalker
//
//  Created by Skywind on 2018/6/7.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

struct OpenHourModel: Codable {
    var weekDay: Int
    var from: String
    var end: String
}

struct WorkTimeInfoModel: Codable {
    var ouId: Int
    var openHour: [OpenHourModel]?
}

struct WorkTimeModel: Codable {
    var weekIndex: [Int]?
    var from: String?
    var end: String?
    var price: Int?
}

class ServiceHoursManager: NSObject {
    /// SH001 取得服務時間 
    static func apiGetOpenHours(success: @escaping (_ response: BaseModel<[WorkTimeModel]>?) -> Void,
                                failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,"ouType":OperatingManager.getUserOuType()]
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.ServiceHours.getOpenHours, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorkTimeInfoModel>.self)
                let syscode = result?.syscode ?? 500
                let sysmsg = result?.sysmsg ?? LocalizedString("Lang_GE_014")
                var model = BaseModel<[WorkTimeModel]>(syscode: syscode, sysmsg: sysmsg, data: nil)
                if let openHour = result?.data?.openHour {
                    model.data = ServiceHoursManager.getWorkTimeModel(openHour)
                }
                success(model)
            }, failure: failure)
        } else {
             SystemManager.showErrorAlert(backToLoginVC: true)
        }
        
//        if let data = APIPatternTool.SH001.data(using: .utf8) {
//            let result = try? JSONDecoder().decode(BaseModel<WorkTimeInfoModel>.self, from: data)
//            let syscode = result?.syscode ?? 500
//            let sysmsg = result?.sysmsg ?? LocalizedString("Lang_GE_014")
//            var model = BaseModel<[WorkTimeModel]>(syscode: syscode, sysmsg: sysmsg, data: nil)
//            if let openHour = result?.data?.openHour {
//                model.data = ServiceHoursManager.getWorkTimeModel(openHour)
//            }
//            success(model)
//        }
        
    }
    /// SH002 編輯服務時間
    static func apiSetOpenHours(openHour: [WorkTimeModel]?,
                                success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String: Any] = ["ouId":ouId,"ouType":OperatingManager.getUserOuType()]
            if let openHour = openHour {
                var arr = [[String:Any]]()
                for model in openHour {
                    if let weekDays = model.weekIndex, let from = model.from, let end = model.end {
                        for weekDay in weekDays {
                            var dic = [String:Any]()
                            dic["weekDay"] = weekDay
                            dic["from"] = from
                            dic["end"] = end
                            arr.append(dic)
                        }
                    }
                }
                parameters["openHour"] = arr
            }
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.ServiceHours.setOpenHours, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    static func getWorkTimeModel(_ openHourModelArray: [OpenHourModel]) -> [WorkTimeModel] {
        // 先找出相同的開始時間
        var sameFromTimeIndexArray:[[Int]] = []
        let fromStringArray = openHourModelArray.enumerated().map{ $0.element.from }
        let set = Set(fromStringArray).sorted()
        for string in set {
            let sameFromIndex = fromStringArray.enumerated().filter{ $0.element == string }.map{ $0.offset }
            sameFromTimeIndexArray.append(sameFromIndex)
        }
        
        var sameTimeIndexArray: [[Int]] = []
        var notSameTimeIndexArray: [Int] = []
        var modelArray:[WorkTimeModel] = []
        for formIndex in sameFromTimeIndexArray {
            if formIndex.count > 1 {
                // 再從相同的開始時間中找出相同的結束時間
                let endStringArray = openHourModelArray.enumerated().filter{ formIndex.contains($0.offset) }.map{ $0.element.end }
                let set = Set(endStringArray).sorted()
                for string in set {
                    let sameEndIndex = endStringArray.enumerated().filter{ $0.element == string }.map{ formIndex[$0.offset] }
                    if sameEndIndex.count > 1 {
                        sameTimeIndexArray.append(sameEndIndex)
                    } else {
                        notSameTimeIndexArray.append(sameEndIndex.first!)
                    }
                }
            } else {
                notSameTimeIndexArray.append(formIndex.first!)
            }
        }
        
        for arr in sameTimeIndexArray {
            let from = openHourModelArray[arr.first!].from
            let end = openHourModelArray[arr.first!].end
            modelArray.append(WorkTimeModel(weekIndex: arr.enumerated().map{ openHourModelArray[$0.element].weekDay }, from: from, end: end, price: nil))
        }
        
        for index in notSameTimeIndexArray {
            let model = openHourModelArray[index]
            modelArray.append(WorkTimeModel(weekIndex: [model.weekDay], from: model.from, end: model.end, price: nil))
        }
        
        return modelArray
    }
}
