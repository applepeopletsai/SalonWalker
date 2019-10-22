//
//  DesignerServiceManager.swift
//  SalonWalker
//
//  Created by Skywind on 2018/6/6.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum SelectionType: Int, Codable {
    case OnlySelect, SingleSelection, MultipleSelection
}

struct SvcCategoryModel: Codable, Equatable {
    var sfciiId: Int?
    var iconUrl: String?
    var type: String?
    var name: String
    var price: Int?
    var hours: Int?
    var svcClass: [SvcClassModel]?
    
    var selectionType: SelectionType?
    var select: Bool?
    var selectSvcClass: [SvcClassModel]?    // 選取的服務項目(多選)
    var serviceItemArray: [SvcClassModel]?  // 顯示資料陣列
    
    static func ==(lhs: SvcCategoryModel, rhs: SvcCategoryModel) -> Bool {
        return lhs.name == rhs.name
    }
}

struct SvcClassModel: Codable, Equatable {
    var open: Bool?
    var name: String
    var price: Int?
    var hours: Int?
    var svcItems: [SvcItemsModel]?
    var svcProduct: [SvcProductModel]?
    var dsciId: [Int]?
    
    static func == (lhs: SvcClassModel, rhs: SvcClassModel) -> Bool {
        return lhs.name == rhs.name
    }
}

struct SvcItemsModel: Codable, Equatable {
    var name: String
    var price: Int?
    var hours: Int?
    
    static func == (lhs: SvcItemsModel, rhs: SvcItemsModel) -> Bool {
        return lhs.name == rhs.name
    }
}

struct SvcProductModel: Codable, Equatable {
    var dsciId: Int?
    var brand: String?
    var product: String?
    var imgUrl: String?
    var imageLocalIdentifier: String?
}

struct SvcPlaceModel: Codable {
    var pId: Int
    var nickName: String
    var cityName: String?
    var areaName: String?
    var address: String?
    var headerImgUrl: String?
    
    var select: Bool?
}

struct SvcItemsInfoModel: Codable {
    var itemId: String?
    var ouId: Int
    var svcCategory: [SvcCategoryModel]?
}

struct SvcPlaceInfoModel: Codable {
    var meta: MetaModel
    var svcPlace: [SvcPlaceModel]?
}

struct ServiceItemModel {
    var iconImgUrl: String
    var itemTitle: String
    var price: Int
    var product: [SvcProductModel]?
    var expand: Bool
}

class DesignerServiceManager: NSObject {
    
    /// DS001 取得服務定價項目 (設計師-服務設定) 
    static func apiGetSvcItems(success: @escaping (_ response: BaseModel<SvcItemsInfoModel>?) -> Void,
                               failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId]
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.DesignerService.getSvcItems, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<SvcItemsInfoModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
        
//        if let data = APIPatternTool.DS001.data(using: .utf8) {
//            let result = try? JSONDecoder().decode(BaseModel<SvcItemsInfoModel>.self, from: data)
//            success(result)
//        }
    }
    
    /// DS002 編輯服務定價項目 (設計師-服務設定)
    static func apiSetSvcItems(model: SvcItemsInfoModel,
                               success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                               failure: @escaping failureClosure) {
        var categoryArray = [[String:Any]]()
        if let svcCategory = model.svcCategory {
            for category in svcCategory {
                var svcCategoryDic = [String:Any]()
                
                if let price = category.price {
                    svcCategoryDic["name"] = category.name
                    svcCategoryDic["price"] = price
                    if let sfciiId = category.sfciiId {
                        svcCategoryDic["sfciiId"] = sfciiId
                    }
                    if let type = category.type {
                        svcCategoryDic["type"] = type
                    }
                    if let hours = category.hours {
                        svcCategoryDic["hours"] = hours
                    }
                }
                
                if let svcClass = category.svcClass {
                    var svcClassArray = [[String:Any]]()
                    
                    for model in svcClass {
                        var svcClassDic = [String:Any]()
                        if let price = model.price {
                            svcClassDic["name"] = model.name
                            svcClassDic["price"] = price
                            
                            if let open = model.open {
                                svcClassDic["open"] = open
                            }
                            if let hours = model.hours {
                                svcClassDic["hours"] = hours
                            }
                        }
                        
                        if let svcItems = model.svcItems {
                            var svcItemsArray = [[String:Any]]()
                            for model in svcItems {
                                var svcItemsDic = [String:Any]()
                                if let price = model.price {
                                    svcItemsDic["name"] = model.name
                                    svcItemsDic["price"] = price
                                    if let hours = model.hours {
                                        svcItemsDic["hours"] = hours
                                    }
                                    svcItemsArray.append(svcItemsDic)
                                }
                            }
                            if svcItemsArray.count > 0 { svcClassDic["svcItems"] = svcItemsArray }
                        }
                        
                        if let svcProduct = model.svcProduct {
                            var array = [Int]()
                            for model in svcProduct {
                                if let dsciId = model.dsciId {
                                    array.append(dsciId)
                                }
                            }
                            svcClassDic["dsciId"] = array
                        }
                        if svcClassDic.count > 0 { svcClassArray.append(svcClassDic) }
                    }
                    if svcClassArray.count > 0 { svcCategoryDic["svcClass"] = svcClassArray }
                }
                if svcCategoryDic.count > 0 { categoryArray.append(svcCategoryDic) }
            }
        }
        
        let dic: [String: Any] = ["itmeId":model.itemId ?? "","ouId":model.ouId,"svcCategory":categoryArray]
        
        APIManager.sendPostRequestWith(parameters: ["svcItemsJsonData":dic], path: ApiUrl.DesignerService.setSvcItems, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// DS004 取得已設定服務地點
    static func apiGetSetSvcPlace(page: Int = 1,
                                  pMax: Int = 30,
                                  placeKeyWord: String?,
                                  success: @escaping (_ response: BaseModel<SvcPlaceInfoModel>?) -> Void,
                                  failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId,"page":page,"pMax":pMax]
            if let placeKeyWord = placeKeyWord, placeKeyWord.count > 0 {
                parameters["placeKeyWord"] = placeKeyWord
            }
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.DesignerService.getSetSvcPlace, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<SvcPlaceInfoModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }

    }
    
    /// DS005 搜尋服務地點
    static func apiGetSvcPlace(placeKeyWord: String?,
                               success: @escaping (_ response: BaseModel<SvcPlaceInfoModel>?) -> Void,
                               failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId]
            if let placeKeyWord = placeKeyWord, placeKeyWord.count > 0 {
                parameters["placeKeyWord"] = placeKeyWord
            }
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.DesignerService.getSvcPlace, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<SvcPlaceInfoModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// DS006 新增服務地點
    static func apiInsertSvcPlace(pId: [Int],
                                  success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                  failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String: Any] = ["ouId":ouId,"pId":pId]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.DesignerService.insertSvcPlace, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// DS007 刪除服務地點
    static func apiDelSvcPlace(pId: [Int],
                               success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                               failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String: Any] = ["ouId":ouId,"pId":pId]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.DesignerService.delSvcPlace, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    // Method
    static func getPaymentType(_ model: DesignerDetailModel) -> String {
        var text = ""
        if let paymentArray = model.paymentType {
            paymentArray.forEach { (string) in
                text.append((text.count == 0) ? string : "、\(string)")
            }
        }
        return text
    }
    
    static func getServiceItems(_ model: DesignerDetailModel) -> [ServiceItemModel] {
        var array: [ServiceItemModel] = []
        if let svcCategory = model.svcCategory {
            for category in svcCategory {
                var model = ServiceItemModel(iconImgUrl: category.iconUrl ?? "", itemTitle: category.name, price: category.price ?? 0 ,product: [], expand: false)
                
                if let svcClass = category.svcClass {
                    for class_ in svcClass {
                        var model_class = model
                        model_class.itemTitle.append(" \(class_.name)")
                        if let svcItem = class_.svcItems {
                            for item in svcItem {
                                var model_item = model_class
                                model_item.itemTitle.append(" \(item.name)  $\(item.price ?? 0)")
                                if let svcProduct = class_.svcProduct {
                                    for product in svcProduct {
                                        model_item.product?.append(product)
                                    }
                                }
                                array.append(model_item)
                            }
                        } else {
                            model_class.itemTitle.append("  $\(class_.price ?? 0)")
                            if let svcProduct = class_.svcProduct {
                                for product in svcProduct {
                                    model_class.product?.append(product)
                                }
                            }
                            array.append(model_class)
                        }
                    }
                } else {
                    model.itemTitle.append("  $\(category.price ?? 0)")
                    array.append(model)
                }
            }
        }
        return array
    }
}
