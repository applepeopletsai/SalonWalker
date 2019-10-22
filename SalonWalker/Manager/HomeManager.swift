//
//  HomeManager.swift
//  SalonWalker
//
//  Created by Daniel on 2018/5/7.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

struct MetaModel: Codable {
    var count: Int
    var page: Int
    var pMax: Int
    var totalPage: Int
}

struct ArticleModel: Codable {
    var seArticlesId: Int?
    var maArticleId: Int?
    var title: String?
    var titleColor: String?
    var imgUrl: String?
    var startTime: String?
    var frame: String? // 方形: square / 長方形: rectangle / 圓形 : circle
}

struct ArticleContentModel: Codable {
    var title: String
    var imgUrl: String
    var content: String?
    var startTime: String
    var redactor: String?
}

struct DesignerListModel: Codable {
    var ouId: Int                // 設計師/業主代碼
    var dId: Int
    var isRes: Bool              // 是否可以預約
    var isTop: Bool              // 是否為優良評價設計師 (綠色標籤)
    var isFav: Bool
    var nickName: String
    var headerImgUrl: String?
    var distance: Double
    var lat: Double
    var lng: Double
    var experience: Int
    var licenseName: String?
    var serviceItem: String
    var servicePrice: Int
    var evaluationAve: Double
    var evaluationTotal: Int
    var coverImgUrl: String
    var cityName: String?
    var areaName: String?
    var langName: String?
}

struct HotDesignerListModel: Codable {
    var meta: MetaModel
    var designerList: [DesignerListModel]?
}

struct FashionSelectedArticleModel: Codable {
    var type1: ArticleModel?
    var type2: ArticleModel?
    var type3: ArticleModel?
    var tips: [ArticleModel]?
    var tools: [ArticleModel]?
}

struct FashionArticleModel: Codable {
    var meta: MetaModel
    var magazineArticles: [ArticleModel]
}

struct DayPricesModel: Codable {
    var workdayPrices: Int
    var holidayPrices: Int
}

struct LeasePricesModel: Codable {
    var prices: Int
}

struct ProviderListModel: Codable {
    var ouId: Int
    var pId: Int
    var isFav: Bool
    var nickName: String
    var lat: Double
    var lng: Double
    var city: String
    var area: String
    var svcHoursPrices: DayPricesModel?
    var svcTimesPrices: DayPricesModel?
    var svcLeasePrices: LeasePricesModel?
    var evaluationAve: Double
    var evaluationTotal: Int
    var coverImgUrl: String
}

struct HotProviderListModel: Codable {
    var meta: MetaModel
    var providerList: [ProviderListModel]?
    var designerList: [DesignerListModel]?
}

class HomeManager: NSObject {
    
    /// H001 首頁 - 流行趨勢(取得精選文章列表)
    static func apiFashionSelectedArticles(success: @escaping (_ response: BaseModel<FashionSelectedArticleModel>?) -> Void,
                                           failure: @escaping failureClosure) {
        
//        if let data = APIPatternTool.H001.data(using: .utf8) {
//            do {
//                let result = try JSONDecoder().decode(BaseModel<FashionSelectedArticleModel>.self, from: data)
//                success(result)
//            } catch {
//                print(error)
//            }
//        }
        
        APIManager.sendGetRequestWith(parameters: nil, path: ApiUrl.Home.fashionSelectedArticles, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<FashionSelectedArticleModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// H002 首頁 - 流行趨勢(取得雜誌文章列表)
    static func apiFashionArticle(page: Int = 1,
                                  pMax: Int = 30,
                                  success: @escaping (_ response: BaseModel<FashionArticleModel>?) -> Void,
                                  failure: @escaping failureClosure) {
        let parameters = ["page":page,"pMax":pMax]
        APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Home.fashionArticle, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<FashionArticleModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// H003 首頁 - 流行趨勢(取得文章內容)
    static func apiFashionArticleContent(seArticlesId: Int?,
                                         maArticleId: Int?,
                                         success: @escaping (_ response: BaseModel<ArticleContentModel>?) -> Void,
                                         failure: @escaping failureClosure) {
        var parameters = [String: Int]()
        
        if let seArticlesId = seArticlesId {
            parameters["seArticlesId"] = seArticlesId
        }
        
        if let maArticleId = maArticleId {
            parameters["maArticleId"] = maArticleId
        }
        
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Home.fashionArticleContent, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<ArticleContentModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// H004 首頁 - 熱門推薦
    static func apiGetHotDesignerList(lat: Double?,
                                      lng: Double?,
                                      page: Int = 1,
                                      pMax: Int = 30,
                                      success: @escaping (_ response: BaseModel<HotDesignerListModel>?) -> Void,
                                      failure: @escaping failureClosure) {
        let mId = UserManager.sharedInstance.mId ?? 0
//        if let mId = UserManager.sharedInstance.mId {
            var parameters: [String:Any] = ["mId":mId,"page":page,"pMax":pMax]
            
            if let lat = lat, let lng = lng {
                parameters["lat"] = lat
                parameters["lng"] = lng
            }
            
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Home.getHotDesignerList, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<HotDesignerListModel>.self)
                success(result)
            }, failure: failure)
//        } else {
//            SystemManager.showErrorAlert(backToLoginVC: true)
//        }
    }
    
    /// H005 首頁 - 窩藏名單
    static func apiGetFavDesignerList(lat: Double?,
                                      lng: Double?,
                                      page: Int = 1,
                                      pMax: Int = 30,
                                      success: @escaping (_ response: BaseModel<HotDesignerListModel>?) -> Void,
                                      failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            var parameters: [String:Any] = ["mId":mId,"page":page,"pMax":pMax]
            
            if let lat = lat, let lng = lng {
                parameters["lat"] = lat
                parameters["lng"] = lng
            }
            
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Home.getFavDesignerList, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<HotDesignerListModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// H006 新增/移除名單收藏
    static func apiEditFavDesignerList(ouId: Int,
                                       act: String,
                                       success: @escaping (_ response: BaseModel<EmptyModel>?) -> Void,
                                       failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            let parameters: [String:Any] = ["mId":mId,"ouId":ouId,"act":act]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Home.editFavDesignerList, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<EmptyModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    /// H007 全站排行/附近 搜尋
    static func apiGetTopOrNearbyDesignerList(lat: Double?,
                                              lng: Double?,
                                              page: Int = 1,
                                              pMax: Int = 30,
                                              cityName: String?,
                                              areaName: [String]?,
                                              cons: Int?, // 條件(1:距離排序,2:評分排序)
                                              keyWord: String?,
                                              success: @escaping (_ response: BaseModel<HotDesignerListModel>?) -> Void,
                                              failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            var parameters: [String:Any] = ["mId":mId,"page":page,"pMax":pMax]
            
            if let lat = lat, let lng = lng {
                parameters["lat"] = lat
                parameters["lng"] = lng
            }
            
            if let cityName = cityName {
                parameters["cityName"] = cityName
            }
            
            if let areaName = areaName {
                parameters["areaName"] = areaName
            }
            
            if let cons = cons {
                parameters["cons"] = cons
            }
            
            if let keyWord = keyWord {
                parameters["keyWord"] = keyWord
            }
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Home.getTopOrNearbyDesgignerList, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<HotDesignerListModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    
    #if SALONWALKER
    /// H008 自訂搜尋
    static func apiGetSpDesignerList(page: Int = 1,
                                     pMax: Int = 30,
                                     model: CustomSearchDesignerModel,
                                     success: @escaping (_ response: BaseModel<HotDesignerListModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        if let mId = UserManager.sharedInstance.mId {
            var parameters: [String:Any] = ["mId": mId,
                                            "page": page,
                                            "pMax": pMax,
                                            "evaluationAvgStart": model.evaluationAvgStart,
                                            "evaluationAvgEnd": model.evaluationAvgEnd,
                                            "experienceStart": model.experienceStart,
                                            "experienceEnd": model.experienceEnd]
            if let lat = model.lat, let lng = model.lng {
                parameters["lat"] = lat
                parameters["lng"] = lng
            }
            if let cityName = model.selectCity?.cityName {
                parameters["cityName"] = cityName
            }
            if let areaName = model.selectArea?.areaName {
                parameters["areaName"] = areaName
            }
            if let sex = model.sex {
                parameters["sex"] = sex
            }
            if let license = model.license {
                parameters["license"] = license
            }
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Home.getSpDesignerList, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<HotDesignerListModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert()
        }
    }
    #endif
    
    /// H009 熱門場地
    static func apiGetProviderList(page: Int = 1,
                                   pMax: Int = 30,
                                   cityName: String?,
                                   areaName: [String]?,
                                   keyWord: String?,
                                   success: @escaping (_ response: BaseModel<HotProviderListModel>?) -> Void,
                                   failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String: Any] = ["ouId":ouId,"ouType":OperatingManager.getUserOuType(),"page":page,"pMax":pMax]
            if let cityName = cityName {
                parameters["cityName"] = cityName
            }
            if let areaName = areaName {
                parameters["areaName"] = areaName
            }
            if let keyWord = keyWord {
                parameters["keyWord"] = keyWord
            }
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Home.getProviderList, success: { (response) in
                
                let result = APIManager.decode(response: response, type: BaseModel<HotProviderListModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// H010 新增 / 移除名單收藏 (設計師/業者)
    static func apiEditFavProviderList(pId: Int?,
                                       dId: Int?,
                                       act: String,
                                       success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                       failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String: Any] = ["ouId":ouId,"ouType":OperatingManager.getUserOuType(),"act":act]
            
            if let pId = pId {
                parameters["pId"] = pId
            }
            
            if let dId = dId {
                parameters["dId"] = dId
            }
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Home.editFavProviderList, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }

    /// H011 我的窩客牆
    static func apiGetFavProviderList(page: Int = 1 ,
                                      pMax: Int = 30,
                                      success: @escaping (_ response: BaseModel<HotProviderListModel>?) -> Void,
                                      failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            
            let parameters: [String: Any] = ["ouId":ouId,"ouType":OperatingManager.getUserOuType(),"page":page,"pMax":pMax]
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Home.getFavProviderList, success: { (response) in
                
                let result = APIManager.decode(response: response, type: BaseModel<HotProviderListModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
}


