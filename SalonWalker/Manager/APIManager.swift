//
//  APIManager.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/21.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

typealias successClosure = (_ response: DataResponse<Any>) -> Void
typealias failureClosure = (_ error: Error?) -> Void

struct BaseModel<T: Codable>: Codable {
    var syscode: Int
    var sysmsg: String
    var data: T?
}

struct EmptyModel: Codable {}

struct ApiUrl {
    private struct Domain {
        static let DEV = "http://salonwalker-tst.skywind.com.tw:8025/api/"
//        static let DEV = "http://192.168.1.36/api/"  // 內部正式機 by Josh
        static let UAT = "http://137.116.133.132/api/"
        static var current: String {
            #if DEV
            return Domain.DEV
            #else
            return Domain.UAT
            #endif
        }
    }
    
    struct System {
        // S001 取得版號
        static var version: String { return Domain.current + "System/Version" }
        // S002 新增、編輯及刪除暫存圖片
        static var tempImage: String { return Domain.current + "System/TempImage" }
        // S003 取得手機國際區碼
        static var getPhoneCode: String { return Domain.current + "System/GetPhoneCode" }
        // S004 取得 語系列表
        static var getSystemLang: String { return Domain.current + "System/GetSystemLang" }
        // S005 取得縣市區域列表
        static var getCityCode: String { return Domain.current + "System/GetCityCode" }
        // S006 新增、編輯產品圖片
        static var productTempImage: String { return Domain.current + "System/ProductTempImage" }
        // S007 取得服務條款
        static var getSvcClause: String { return Domain.current + "System/GetSvcClause" }
        // S008 新增、編輯及刪除暫存圖片 - 作品集 / 場地照
        static var worksTempPhotos: String { return Domain.current + "System/WorksTempPhotos" }
        // S009 新增、刪除範例照片
        static var orderPhotoTempImage: String { return Domain.current + "System/OrderPhotoTempImage" }
        // S010 取得檢舉原因
        static var getReportedReason: String { return Domain.current + "System/GetReportedReason" }
        // S011 取得意見回饋標籤
        static var getFeedbackLabel: String { return Domain.current + "System/GetFeedbackLabel" }
        // S012 上傳意見回饋圖檔
        static var uploadPhoto: String { return Domain.current + "System/UploadPhoto" }
        // S013 送出意見回饋
        static var giveFeedback: String { return Domain.current + "System/GiveFeedback" }
    }
    
    struct Member {
        // M001 消費者登入
        static var login: String { return Domain.current + "Member/Login" }
        // M002 消費者註冊
        static var register: String { return Domain.current + "Member/Register" }
        // M003 消費者重設密碼、忘記密碼
        static var resetPassword: String { return Domain.current + "Member/ResetPsd" }
        // M004 消費者 發送手機驗證碼、重新發送驗證碼
        static var setVerify: String { return Domain.current + "Member/SetVerify" }
        // M005 取得消費者帳號資訊
        static var getMemberInfo: String { return Domain.current + "Member/GetMemberInfo" }
        // M006 驗證消費者註冊信箱/FB/Google重複性
        static var verifyMemberAccount: String { return Domain.current + "Member/VerifyMemberAccount" }
        // M007 編輯消費者帳號資訊
        static var setMemberInfo: String { return Domain.current + "Member/SetMemberInfo" }
        // M009 編輯消費者設定資訊
        static var setMemberSetting: String { return Domain.current + "Member/SetMemberSetting" }
        // M010 編輯消費者語系設定
        static var setMemberLangSetting: String { return Domain.current + "Member/SetMemberLangSetting" }
        // M011 更改消費者起機號碼
        static var setMemberPhone: String { return Domain.current + "Member/SetMemberPhone" }
        // M012 消費者 更改手機 - 發送手機驗證碼
        static var setChgPhoneVerify: String { return Domain.current + "Member/SetChgPhoneVerify" }
        // M013 消費者 驗證 手機驗證碼
        static var verifyNum: String { return Domain.current + "Member/VerifyNum" }
        // M014 取得消費者推播通知列表
        static var getPushList: String { return Domain.current + "Member/GetPushList" }
        // M015 更改消費者推播通知狀態
        static var pushListChgStatus: String { return Domain.current + "Member/PushListChgStatus" }
        // M016 消費者登出
        static var logout: String { return Domain.current + "Member/Logout" }
    }
    
    struct Operating {
        // O001 設計師/業者登入
        static var login: String { return Domain.current + "Operating/Login" }
        // O002 設計師/業者註冊
        static var register: String { return Domain.current + "Operating/Register" }
        // O003 設計師/業者重設密碼、忘記密碼
        static var resetPassword: String { return Domain.current + "Operating/ResetPsd" }
        // O004 設計師/業者發送手機驗證碼、重新發送驗證碼
        static var setVerify: String { return Domain.current + "Operating/SetVerify" }
        // O005 設計師填寫個人資料
        static var setDesignerInfo: String { return Domain.current + "Operating/SetDesignerInfo" }
        // O006 業者填寫個人資料
        static var setProviderInfo: String { return Domain.current + "Operating/SetProviderInfo" }
        // O007 取得設計師個人資料
        static var getDesignerInfo: String { return Domain.current + "Operating/GetDesignerInfo" }
        // O008 取得業者場地資料
        static var getProviderInfo: String { return Domain.current + "Operating/GetProviderInfo" }
        // O009 取得業者設備項目
        static var getEquipment: String { return Domain.current + "Operating/GetEquipment" }
        // O010 驗證 設計師/業者 註冊信箱/FB/Google重複性
        static var verifyOperatingAccount: String { return Domain.current + "Operating/VerifyOperatingAccount" }
        // O011 編輯 設計師 / 業者 帳號資訊
        static var setOperatingData: String { return Domain.current + "Operating/SetOperatingData" }
        // O013 編輯 設計師/業者 設定資訊
        static var setOperatingSetting: String { return Domain.current + "Operating/SetOperatingSetting" }
        // O014 編輯 設計師 / 業者 語系設定
        static var setOperatingLangSetting: String { return Domain.current + "Operating/SetOperatingLangSetting" }
        // O015 更改 設計師 / 業者 手機號碼
        static var setOperatingPhone: String { return Domain.current + "Operating/SetOperatingPhone" }
        // O017 設計師 / 業者 更改手機 - 發送手機驗證碼
        static var setChgPhoneVerify: String { return Domain.current + "Operating/SetChgPhoneVerify" }
        // O018 設計師/業者 驗證手機驗證碼
        static var verifyNum: String { return Domain.current + "Operating/VerifyNum" }
        // O019 取得設計師/業者推播通知列表
        static var getPushList: String { return Domain.current + "Operating/GetPushList" }
        // O020 取得設計師訂單未回覆小紅點數量
        static var getOrderStatusNum: String { return Domain.current + "Operating/GetOrderStatusNum" }
        // O021 更改設計師/業者推播通知狀態
        static var pushListChgStatus: String { return Domain.current + "Operating/PushListChgStatus" }
        // O022 設計師/業者登出
        static var logout: String { return Domain.current + "Operating/Logout" }
    }
    
    struct Home {
        // H001 首頁 - 流行趨勢(取得文章列表)
        static var fashionSelectedArticles: String { return Domain.current + "Home/FashionSelectedArticles" }
        // H002 首頁 - 流行趨勢(取得雜誌文章列表)
        static var fashionArticle: String { return Domain.current + "Home/FashionArticle" }
        // H003 首頁 - 流行趨勢(取得文章內容)
        static var fashionArticleContent: String { return Domain.current + "Home/FashionArticleContent" }
        // H004 首頁 - 熱門推薦
        static var getHotDesignerList: String { return Domain.current + "Home/GetHotDesignerList" }
        // H005 首頁 - 窩藏名單
        static var getFavDesignerList: String { return Domain.current + "Home/GetFavDesignerList" }
        // H006 新增/移除名單收藏
        static var editFavDesignerList: String { return Domain.current + "Home/EditFavDesignerList" }
        // H007 全站排行/附近 搜尋
        static var getTopOrNearbyDesgignerList: String { return Domain.current + "Home/GetTopOrNearbyDesignerList" }
        // H008 自訂搜尋
        static var getSpDesignerList: String { return Domain.current + "Home/GetSpDesignerList" }
        // H009 熱門場地
        static var getProviderList: String { return Domain.current + "Home/GetProviderList" }
        // H010 新增 / 移除名單收藏 (設計師/業者)
        static var editFavProviderList: String { return Domain.current + "Home/EditFavProviderList" }
        // H011 我的窩客牆
        static var getFavProviderList: String { return Domain.current + "Home/GetFavProviderList" }
    }
    
    struct DesignerService {
        //DS001 取得服務定價項目 (設計師-服務設定)
        static var getSvcItems: String { return Domain.current + "DesignerSvc/GetSvcItems" }
        //DS002 編輯服務定價項目  (設計師-服務設定)
        static var setSvcItems: String { return Domain.current + "DesignerSvc/SetSvcItems" }
        //DS004 取得已設定服務地點 
        static var getSetSvcPlace: String { return Domain.current + "DesignerSvc/GetSetSvcPlace" }
        //DS005 搜尋服務地點
        static var getSvcPlace: String { return Domain.current + "DesignerSvc/GetSvcPlace" }
        //DS006 新增服務地點
        static var insertSvcPlace: String { return Domain.current + "DesignerSvc/InsertSvcPlace" }
        //DS007 刪除服務地點
        static var delSvcPlace: String { return Domain.current + "DesignerSvc/DelSvcPlace" }
    }
    
    struct TransactionSetting {
        //TS001 取得交易設定 (設計師 / 業者)
        static var getOperatingTxnSetting: String { return Domain.current + "TxnSetting/GetOperatingTxnSetting" }
        //TS002 設定交易設定 (設計師 / 業者)
        static var setOperatingTxnSetting: String { return Domain.current + "TxnSetting/SetOperatingTxnSetting" }
        //TS003 取得銀行代碼
        static var getBank: String { return Domain.current + "TxnSetting/GetBank" }
    }
    
    struct ServiceHours {
        //SH001 取得服務時間
        static var getOpenHours: String { return Domain.current + "SvcHours/GetOpenHours" }
        //SH002 編輯服務時間
        static var setOpenHours: String { return Domain.current + "SvcHours/SetOpenHours" }
    }
    
    struct ProviderService {
        // PS001 取得場地業者服務計價
        static var getPlaceSvcPrices: String { return Domain.current + "ProviderSvc/GetPlaceSvcPrices" }
        // PS002 編輯場地業者服務計價
        static var setPlaceSvcPrices: String { return Domain.current + "ProviderSvc/SetPlaceSvcPrices" }
    }
    
    struct Detail {
        // D001 設計師 詳細資訊
        static var getDesignerDetail: String { return Domain.current + "Detail/GetDesignerDetail" }
        // D002 場地業者 詳細資訊
        static var getProviderDetail: String { return Domain.current + "Detail/GetProviderDetail" }
        // D003 評價詳細資訊
        static var getEvaluateDetail: String { return Domain.current + "Detail/GetEvaluateDetail" }
        // D004 設計師詳細頁檢舉
        static var giveDesignerReported: String { return Domain.current + "Detail/GiveDesignerReported" }
        // D005 場地詳細頁檢舉
        static var giveProviderReported: String { return Domain.current + "Detail/GiveProviderReported" }
    }
    
    struct Reservation {
        // R001 取得設計師服務定價項目
        static var getSvcItems: String { return Domain.current + "Reservation/GetSvcItems" }
        // R002 計算預約時間(消費者訂單)
        static var getRecSvcDate: String { return Domain.current + "Reservation/GetRecSvcDate" }
        // R003 取得可預約場地列表
        static var getSvcPlace: String { return Domain.current + "Reservation/GetSvcPlace" }
        // R004 取得窩客推薦相片
        static var getRefPhoto: String { return Domain.current + "Reservation/GetRefPhoto" }
        // R005 確認預約 - 消費者訂單(訂金付款)
        static var memberOrderPayDeposit: String { return Domain.current + "Reservation/MembersOrderPayDeposit" }
        // R006 更改訂單狀態 (消費者訂單)
        static var membersOrderChgStatus: String { return Domain.current + "Reservation/MembersOrderChgStatus" }
        // R007 取得訂單計價方式
        static var getOrderSvcPrices: String { return Domain.current + "Reservation/GetOrderSvcPrices" }
        // R008 取得計價方式
        static var getSvcPrices: String { return Domain.current + "Reservation/GetSvcPrices" }
        // R009 計算預約日期 (設計師訂單)
        static var getSvcTime: String { return Domain.current + "Reservation/GetSvcTime" }
        // R010 確認預約 - 設計師訂單 - 付款
        static var designerOrderPayDeposit: String { return Domain.current + "Reservation/DesignerOrderPayDeposit" }
        // R011 更改訂單狀態 (設計師訂單)
        static var designerOrderChgStatus: String { return Domain.current + "Reservation/DesignerOrderChgStatus" }
        // R012 產生QRcode (場地業者)
        static var qrCodeImgUrl: String { return Domain.current + "Reservation/QRCodeImgUrl" }
        // R014 簽到/簽退 (設計師/消費者)
        static var punchInAndOut: String { return Domain.current + "Reservation/PunchInAndOut" }
        // R015 取得消費者訂單服務項目
        static var getMembersOrderSvcItems: String { return Domain.current + "Reservation/GetMembersOrderSvcItems" }
        // R016 編輯消費者訂單服務項目
        static var setMembersOrderSvcItems: String { return Domain.current + "Reservation/SetMembersOrderSvcItems" }
        // R017 編輯設計師訂單計費方案
        static var setDesignerOrderSvcItems: String { return Domain.current + "Reservation/SetDesignerOrderSvcItems" }
        // R018 訂單 - 付尾款
        static var orderPayFinalPayment: String { return Domain.current + "Reservation/OrderPayFinalPayment" }
    }

    struct Works {
        // W001 取得相片列表（設計師）
        static var getWorksPhotoList: String { return Domain.current + "Works/GetWorksPhotoList" }
        // W002 取得影片列表（設計師）
        static var getWorksVideoList: String { return Domain.current + "Works/GetWorksVideoList" }
        // W003 取得相簿列表（設計師）
        static var getWorksAlbumsList: String { return Domain.current + "Works/GetWorksAlbumsList" }
        // W004 取得相簿相片列表（設計師）
        static var getWorksAlbumsPhotoList: String { return Domain.current + "Works/GetWorksAlbumsPhotoList" }
        // W005 新增相簿（設計師）
        static var addWorksAlbums: String { return Domain.current + "Works/AddWorksAlbums" }
        // W006 編輯相簿名稱/說明（設計師）
        static var editWorksAlbums: String { return Domain.current + "Works/EditWorksAlbums" }
        // W007 刪除相簿（設計師）
        static var delWorksAlbums: String { return Domain.current + "Works/DelWorksAlbums" }
        // W008 設定相簿封面圖片（設計師）
        static var setAlbumsCover: String { return Domain.current + "Works/SetAlbumsCover" }
        // W009 上傳相片（設計師）
        static var uploadPhoto: String { return Domain.current + "Works/UploadPhoto" }
        // W010 上傳影片（設計師）
        static var uploadVideo: String { return Domain.current + "Works/UploadVideo" }
        // W011 編輯相片/影片說明（設計師）
        static var editPhoto: String { return Domain.current + "Works/EditPhoto" }
        // W012 上傳/編輯相簿相片（設計師）
        static var uploadAlbumsPhoto: String { return Domain.current + "Works/UploadAlbumsPhoto" }
        // W013 編輯相簿相片說明（設計師）
        static var editAlbumsPhoto: String { return Domain.current + "Works/EditAlbumsPhoto" }
        // W014 刪除相簿相片 (設計師)
        static var delAlbumsPhoto: String { return Domain.current + "Works/DelAlbumsPhoto" }
        // W015 刪除相片（設計師）
        static var delPhoto: String { return Domain.current + "Works/DelPhoto" }
        // W016 刪除影片 (設計師)
        static var delVideo: String { return Domain.current + "Works/DelVideo" }
    }

    struct Customer {
        // C001 我的客戶清單
        static var getCustomerList: String { return Domain.current + "Customer/GetCustomerList" }
        // C002 刪除我的客戶
        static var delCustomerList: String { return Domain.current + "Customer/DelCustomerList" }
        // C003 取得我的客戶個人資料
        static var getCustomerData: String { return Domain.current + "Customer/GetCustomerData" }
        // C004 編輯我的客戶個人資料
        static var setCustomerData: String { return Domain.current + "Customer/SetCustomerData" }
        // C005 取得我的客戶需求紀錄
        static var getCustomerSvcHistory: String { return Domain.current + "Customer/GetCustomerSvcHistory" }
        // C006 取得我的客戶消費記錄
        static var getCustomerPayHistory: String { return Domain.current + "Customer/GetCustomerPayHistory" }
    }
    
    struct OrderData {
        // OD001 我的行事曆(消費者)
        static var getMemberCalendar: String { return Domain.current + "OrderData/GetMemberCalendar" }
        // OD002 我的行事曆(設計師/場地業者)
        static var getOperatingCalendar: String { return Domain.current + "OrderData/GetOperatingCalendar" }
        // OD003 消費者訂單記錄列表(消費者訂單記錄)
        static var getMemberOrderList: String { return Domain.current + "OrderData/GetMemberOrderList" }
        // OD004 消費者預約訂單記錄列表(設計師查消費者訂單記錄)
        static var getMemberOrderListByD: String { return Domain.current + "OrderData/GetMemberOrderListByD" }
        // OD005 設計師訂單記錄列表(設計師查場地訂單記錄)
        static var getDesignerOrderList: String { return Domain.current + "OrderData/GetDesignerOrderList" }
        // OD006 設計師訂單記錄列表(設計師查場地訂單記錄)
        static var getDesignerOrderListByP: String { return Domain.current + "OrderData/GetDesignerOrderListByP" }
        // OD007 設計師訂單記錄列表(設計師查場地訂單記錄)
        static var getMemberOrderInfo: String { return Domain.current + "OrderData/GetMemberOrderInfo" }
        // OD008 設計師訂單詳細
        static var getDesignerOrderInfo: String { return Domain.current + "OrderData/GetDesignerOrderInfo" }
        // OD009 消費者給予設計師評價 (消費者訂單)
        static var giveDesignerEvaluate: String { return Domain.current + "OrderData/GiveDesignerEvaluate" }
        // OD010 設計師給予場地業者評價 (設計師訂單)
        static var giveProviderEvaluate: String { return Domain.current + "OrderData/GiveProviderEvaluate" }
        // OD011 給予檢舉 (消費者訂單)
        static var giveMemberOrderReported: String { return Domain.current + "OrderData/GiveMemberOrderReported" }
        // OD012 給予檢舉 (設計師訂單)
        static var giveDesignerOrderReported: String { return Domain.current + "OrderData/GiveDesignerOrderReported" }
    }
    
    struct PlacesPhoto {
        // P001 取得相片列表 (場地)
        static var getPlacesPhotoList: String { return Domain.current + "PlacesPhoto/GetPlacesPhotoList" }
        // P002 取得影片列表 (場地)
        static var getPlacesVideoList: String { return Domain.current + "PlacesPhoto/GetPlacesVideoList" }
        // P003 取得相簿列表 (場地)
        static var getPlacesAlbumsList: String { return Domain.current + "PlacesPhoto/GetPlacesAlbumsList" }
        // P004 取得相簿相片列表 (場地)
        static var getPlacesAlbumsPhotoList: String { return Domain.current + "PlacesPhoto/GetPlacesAlbumsPhotoList" }
        // P005 新增相簿 (場地)
        static var addPlacesAlbums: String { return Domain.current + "PlacesPhoto/AddPlacesAlbums" }
        // P006 編輯相簿說明 (場地)
        static var editPlacesAlbums: String { return Domain.current + "PlacesPhoto/EditPlacesAlbums" }
        // P007 刪除相簿 (場地)
        static var delPlacesAlbums: String { return Domain.current + "PlacesPhoto/DelPlacesAlbums" }
        // P008 設定相簿封面圖片 (場地)
        static var setAlbumsCover: String { return Domain.current + "PlacesPhoto/SetAlbumsCover" }
        // P009 上傳相片 (場地)
        static var uploadPhoto: String { return Domain.current + "PlacesPhoto/UploadPhoto" }
        // P010 上傳影片 (場地)
        static var uploadVideo: String { return Domain.current + "PlacesPhoto/UploadVideo" }
        // P011 編輯相片 / 影片說明 (場地)
        static var editPhoto: String { return Domain.current + "PlacesPhoto/EditPhoto" }
        // P012 上傳相簿相片 (場地)
        static var uploadAlbumsPhoto: String { return Domain.current + "PlacesPhoto/UploadAlbumsPhoto" }
        // P013 編輯相簿相片說明 (場地)
        static var editAlbumsPhoto: String { return Domain.current + "PlacesPhoto/EditAlbumsPhoto" }
        // P014 刪除相簿相片 (場地)
        static var delAlbumsPhoto: String { return Domain.current + "PlacesPhoto/DelAlbumsPhoto" }
        // P015 刪除相片 (場地)
        static var delPhoto: String { return Domain.current + "PlacesPhoto/DelPhoto" }
        // P016 刪除影片 (場地)
        static var delVideo: String { return Domain.current + "PlacesPhoto/DelVideo" }
    }
    
    struct PushMessage {
        // PM003 業主發送推播分享場地給設計師
        static var providerSharePlaces: String { return Domain.current + "PushMessage/ProviderSharePlaces" }
        // PM004 設計師修改資訊後，發送推播通知有窩藏該設計師的消費者
        static var designerEditInfo: String { return Domain.current + "PushMessage/DesignerEditInfo" }
    }
}

class APIManager: NSObject {
    
    private struct APIRequestModel: Equatable {
        var type: HTTPMethod
        var parameters: Parameters?
        var path: String
        var success: successClosure?
        var failure: failureClosure?
        
        static func == (lhs: APIManager.APIRequestModel, rhs: APIManager.APIRequestModel) -> Bool {
            return lhs.path == rhs.path
        }
    }
    
    static private var AFManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    static private var getRequestArray = [APIRequestModel]()
    static private var postRequestArray = [APIRequestModel]()
    static private var uploadImageRequestArray = [APIRequestModel]()
    
    // header
    static func headers() -> HTTPHeaders {
        return ["Content-Type":"application/json",
                "salonWalkerKey":"cf3cdea12ce8a086249c7b3eb0061a02",
                "appVersionNo":appVersion,
                "userToken":UserManager.getUserToken(),
                "lang":LanguageManager.currentLanguage(),
                "zone":Date.timeZoneString()]
    }
    
    // GET
    static func sendGetRequestWith(parameters: Parameters?, path: String, success: successClosure?, failure: failureClosure?) {
        debugPrint("API Path: \(path)")
        debugPrint("UserToken: \(UserManager.getUserToken())")
        debugPrint("Header: \(APIManager.headers())")
        debugPrint("Parameters: \(String(describing: parameters))")
        
        DispatchQueue.global().async {
        let model = APIRequestModel(type: .get, parameters: parameters, path: path, success: success, failure: failure)
        addRequestModelArray(model: model)
        // error code: -999 : https://github.com/Alamofire/Alamofire/issues/1684
            AFManager.request(path, method: .get, parameters: parameters, headers: APIManager.headers()).responseJSON { (response) in
                debugPrint(response)
                if response.result.isSuccess {
                    DispatchQueue.main.async {
                        success?(response)
                        removeRequestModelArray(model: model)
                    }
                } else {
                    if response.error?._code == NSURLErrorTimedOut {
                        DispatchQueue.main.async {
                            SystemManager.showTimeOutErrorAlert(tryAgainHandler: {
                                for model in getRequestArray {
                                    sendGetRequestWith(parameters: model.parameters, path: model.path, success: model.success, failure: model.failure)
                                }
                            })
                        }
                    } else {
                        DispatchQueue.main.async {
                            failure?(response.error)
                            removeRequestModelArray(model: model)
                        }
                    }
                }
            }
        }
    }
    
    // POST
    static func sendPostRequestWith(parameters: Parameters?, path: String, success: successClosure?, failure: failureClosure?) {
        debugPrint("API Path: \(path)")
        debugPrint("UserToken: \(UserManager.getUserToken())")
        debugPrint("Header: \(APIManager.headers())")
        debugPrint("Parameters: \(String(describing: parameters))")
        
        DispatchQueue.global().async {
            let model = APIRequestModel(type: .post, parameters: parameters, path: path, success: success, failure: failure)
            addRequestModelArray(model: model)
            AFManager.request(path, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: APIManager.headers()).responseJSON { (response) in
                debugPrint(response)
                if response.result.isSuccess {
                    DispatchQueue.main.async {
                        success?(response)
                        removeRequestModelArray(model: model)
                    }
                } else {
                    if response.error?._code == NSURLErrorTimedOut {
                        DispatchQueue.main.async {
                            SystemManager.showTimeOutErrorAlert(tryAgainHandler: {
                                for model in postRequestArray {
                                    sendPostRequestWith(parameters: model.parameters, path: model.path, success: model.success, failure: model.failure)
                                }
                            })
                        }
                    } else {
                        DispatchQueue.main.async {
                            failure?(response.error)
                            removeRequestModelArray(model: model)
                        }
                    }
                }
            }
        }
    }
    
    // Upload Image
    // uploadImageKey 是上傳圖片時的key 值，如果api 的key 有更換，再輸入新的key，否則不用輸入
    static func uploadImageRequestWith(images: [UIImage], uploadImageKey: String = "uploadFile[]", parameters: Parameters, path: String, success: @escaping successClosure, failure: @escaping failureClosure) {
        DispatchQueue.global().async {
            AFManager.upload(
                multipartFormData: { multipartFormData in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyyMMddHHss"
                    
                    // 加入照片
                    for image in images {
                        let data = image.jpegData(compressionQuality: 0.5)
                        let dateString = formatter.string(from: Date())
                        let fileName = dateString + ".jpg"
                        //
                        multipartFormData.append(data!, withName: uploadImageKey, fileName: fileName, mimeType: "image/jpg")
                    }
                    
                    // 加入其餘參數
                    for (key, value) in parameters {
                        multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                    }
            },
                to: path,
                method:.post,
                headers:APIManager.headers(),
                encodingCompletion: { response in
                    switch response {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            DispatchQueue.main.async {
                                success(response)
                            }
                        }
                        
                        // 進度條
                        upload.uploadProgress(closure: { progress in
                            print(progress.fractionCompleted)
                        })
                        break
                    case .failure(let encodingError):
                        //在上傳圖片時，如果有錯誤，則不進行動作
//                        if encodingError._code == NSURLErrorTimedOut {
//                            SystemManager.showTimeOutErrorAlert(tryAgainHandler: {
//                                APIManager.uploadImageRequestWith(images: images, parameters: parameters, path: path, success: success, failure: failure)
//                            })
//                        } else {
//                            failure(encodingError)
//                        }
                        DispatchQueue.main.async {
                            failure(encodingError)
                        }
                        break
                    }
            })
        }
    }
    
    // Upload Video
    // uploadVideoKey 是上傳圖片時的key 值，如果api 的key 有更換，再輸入新的key，否則不用輸入
    static func uploadVideoRequestWith(videos: [AVURLAsset], uploadVideoKey: String = "uploadFile[]", parameters: Parameters, path: String, success: @escaping successClosure, failure: @escaping failureClosure) {
        DispatchQueue.global().async {
            AFManager.upload(
                multipartFormData: { multipartFormData in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyyMMddHHss"
                    
                    // 加入影片
                    for asset in videos {
                        if let videoData = FileManager.default.contents(atPath: asset.url.path) {
                            let dateString = formatter.string(from: Date())
                            let fileName = dateString + ".mp4"
                            multipartFormData.append(videoData, withName: uploadVideoKey, fileName: fileName, mimeType: "video/mp4")
                        }
                    }
                    
                    // 加入其餘參數
                    for (key, value) in parameters {
                        multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                    }
            },
                to: path,
                method:.post,
                headers:APIManager.headers(),
                encodingCompletion: { response in
                    switch response {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            DispatchQueue.main.async {
                                success(response)
                            }
                        }
                        
                        // 進度條
                        upload.uploadProgress(closure: { progress in
                            print(progress.fractionCompleted)
                        })
                        break
                    case .failure(let encodingError):
                        //在上傳圖片時，如果有錯誤，則不進行動作
//                        if encodingError._code == NSURLErrorTimedOut {
//                            SystemManager.showTimeOutErrorAlert(tryAgainHandler: {
//                                APIManager.uploadImageRequestWith(images: images, parameters: parameters, path: path, success: success, failure: failure)
//                            })
//                        } else {
//                            failure(encodingError)
//                        }
                        DispatchQueue.main.async {
                            failure(encodingError)
                        }
                        break
                    }
            })
        }
    }
    
    static private func addRequestModelArray(model: APIRequestModel) {
        DispatchQueue.main.async {
            switch model.type {
            case .get:
                if !getRequestArray.contains(model) {
                    getRequestArray.append(model)
                }
                break
            case .post:
                if !postRequestArray.contains(model) {
                    postRequestArray.append(model)
                }
                break
            default: break
            }
        }
    }
    
    static private func removeRequestModelArray(model: APIRequestModel) {
        DispatchQueue.main.async {
            switch model.type {
            case .get:
                if let index = getRequestArray.index(of: model) {
                    getRequestArray.remove(at: index)
                }
                break
            case .post:
                if let index = postRequestArray.index(of: model) {
                    postRequestArray.remove(at: index)
                }
                break
            default: break
            }
        }
    }
    
    // Decode
    static func decode<T: Codable>(response: DataResponse<Any>, type: T.Type) -> T? {
        if let data = response.data {
            do {
                let result = try JSONDecoder().decode(type, from: data)
                return result
            } catch DecodingError.keyNotFound(let key, let context) {
                print("KeyNotFound, key: \(key)")
                print("CodingPath: \(context.codingPath)")
                print("Debug description: \(context.debugDescription)")
                return nil
            } catch DecodingError.typeMismatch(let type, let context) {
                print("TypeMismatch, type: \(type)")
                print("CodingPath: \(context.codingPath)")
                print("Debug description: \(context.debugDescription)")
                return nil
            } catch DecodingError.dataCorrupted(let context) {
                print("DataCorrupted")
                print("CodingPath: \(context.codingPath)")
                print("Debug description: \(context.debugDescription)")
                return nil
            } catch DecodingError.valueNotFound(let type, let context) {
                print("ValueNotFound, type: \(type)")
                print("CodingPath: \(context.codingPath)")
                print("Debug description: \(context.debugDescription)")
                return nil
            } catch {
                print("Decoder Error: \(error.localizedDescription)")
                return nil
            }
        } else {
            return nil
        }
    }
}
