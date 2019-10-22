//
//  SystemManager.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/21.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Alamofire
import SwiftMessages
import AVFoundation

let DidRecoverConnection = "didRecoverConnection"
let kAPISyscode_501 = "APISyscode_501"
private let NotReachableNetworkBanner = "NotReachableNetworkBanner"
private let ReachableNetWorkBanner = "ReachableNetWorkBanner"
private let ErrorMessageBanner = "ErrorMessageBanner"
private let WarningMessageBanner = "WarningMessageBanner"

enum AppIdentity: String {
    case SalonWalker = "SalonWalker"
    case SalonMaker = "SalonMaker"
}

struct VersionModel: Codable {
    var lastVersion: String
    var upgrade: Int
}

struct TempImageModel: Codable {
    var tempImgId: Int
    var licenseImgId: Int?
    var coverImgId: Int?
    var imgUrl: String
    var actTime: String?
}

struct PhoneCodeModel: Codable {
    var country: String
    var internationalPrefix: String
}

struct LangModel: Codable {
    var slId: Int
    var langCode: String
    var langName: String
}

struct SystemLangModel: Codable {
    var lang: [LangModel]
}

struct CityCodeModel: Codable {
    struct AreaModel: Codable {
        var zcId: Int?
        var areaName: String?
        var zipCode: String?
    }
    
    struct CityModel: Codable {
        var areaRangCode: String?
        var cityName: String?
        var area: [AreaModel]?
        
        var keyword: String?
    }
    
    var city: [CityModel]
}

struct SvcClauseModel: Codable {
    var svcClause: [String]?
}

struct WorksTempPhotosModel: Codable {
    var tempImgId: Int
    var dwpId: [Int]?
    var dwvId: [Int]?
    var dwapId: [Int]?
    var pppId: [Int]?
    var ppvId: [Int]?
    var ppapId: [Int]?
    var imgUrl: String?
    var actTime: String
}

struct OrderPhotoModel: Codable {
    var orderPhoto: [TempImageModel]
}

struct ReportedReasonModel: Codable {
    
    struct ReportedItemModel: Codable {
        var rrId: Int
        var reason: String
    }
    var reportedItem: [ReportedItemModel]?
}

struct FeedbackModel: Codable {
    
    struct Label: Codable {
        var flId: Int
        var content: String
    }
    
    var feedbackLabel: [Label]
}

class SystemManager: NSObject {
    private static let sharedInstance = SystemManager()
    
    private var deepLinkInfo: [AnyHashable:Any]?
    private let networkManager = Alamofire.NetworkReachabilityManager()
    private var networkStatus = (Alamofire.NetworkReachabilityManager()?.isReachable)! ? Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus.reachable(.wwan) : Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus.notReachable
    
    // MARK: Set
    static func saveAppIdentity(_ identity: AppIdentity) {
        UserDefaults.standard.set(identity.rawValue, forKey: "AppIdentity")
        UserDefaults.standard.synchronize()
    }
    
    static func savePhoencodeModel(_ phoneCodeModel: [PhoneCodeModel]) {
        if let encodeModel = try? PropertyListEncoder().encode(phoneCodeModel) {
            UserDefaults.standard.set(encodeModel, forKey: "PhoneCodeModel")
            UserDefaults.standard.synchronize()
        }
    }
    
    static func saveCityCodeModel(_ cityCodeModel: CityCodeModel) {
        if let encodeModel = try? PropertyListEncoder().encode(cityCodeModel) {
            UserDefaults.standard.set(encodeModel, forKey: "CityCodeModel")
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: Get
    static func getAppIdentity() -> AppIdentity {
        let appIdentity = UserDefaults.standard.string(forKey: "AppIdentity")
        return AppIdentity(rawValue: appIdentity!)!
    }
    
    static func getPhoneCodeModel() -> [PhoneCodeModel]? {
        if let data = UserDefaults.standard.object(forKey: "PhoneCodeModel") as? Data {
            if let decodeModel = try? PropertyListDecoder().decode([PhoneCodeModel].self, from: data) {
                return decodeModel
            }
        }
        return nil
    }
    
    static func getCityCodeModel() -> CityCodeModel? {
        if let data = UserDefaults.standard.object(forKey: "CityCodeModel") as? Data {
            if let decodeModel = try? PropertyListDecoder().decode(CityCodeModel.self, from: data) {
                return decodeModel
            }
        }
        return nil
    }
    
    static func getCityNameArray() -> [String] {
        return SystemManager.getCityCodeModel()!.city.map({ $0.cityName ?? "" })
    }
    
    static func getSelectCityIndex(cityName: String) -> Int? {
        return SystemManager.getCityNameArray().index(of: cityName)
    }
    
    static func getSelectCityIndex(city: CityCodeModel.CityModel?) -> Int? {
        if let cityName = city?.cityName {
            return SystemManager.getSelectCityIndex(cityName: cityName)
        }
        return nil
    }
    
    static func getSelectCityModel(cityName: String) -> CityCodeModel.CityModel? {
        if let index = SystemManager.getSelectCityIndex(cityName: cityName), let city = SystemManager.getCityCodeModel()?.city, index < city.count {
            return city[index]
        }
        return nil
    }
    
    static func getAreaNameArray(cityName: String) -> [String]? {
        if let city = SystemManager.getSelectCityModel(cityName: cityName) {
            return SystemManager.getAreaNameArray(city: city)
        }
        return nil
    }
    
    static func getAreaNameArray(city: CityCodeModel.CityModel) -> [String]? {
        return city.area?.map({ $0.areaName ?? "" })
    }
    
    static func getSelectAreaIndex(cityName: String, areaName: String) -> Int? {
        if let city = SystemManager.getSelectCityModel(cityName: cityName), let areaNameArray = SystemManager.getAreaNameArray(city: city) {
            return areaNameArray.index(of: areaName)
        }
        return nil
    }
    
    static func getSelectAreaIndex(city: CityCodeModel.CityModel?, area: CityCodeModel.AreaModel?) -> Int? {
        
        if let city = city, let area = area, let areaNameArray = SystemManager.getAreaNameArray(city: city), let areaName = area.areaName {
            return areaNameArray.index(of: areaName)
        }
        return nil
    }
    
    static func getSelectAreaModel(cityName: String, areaName: String) -> CityCodeModel.AreaModel? {
        if let city = SystemManager.getSelectCityModel(cityName: cityName), let area = city.area, let index = SystemManager.getSelectAreaIndex(cityName: cityName, areaName: areaName), index < area.count {
            return area[index]
        }
        return nil
    }
    
    static func getZcId(cityName: String, areaName: String) -> Int? {
        if let area = SystemManager.getSelectAreaModel(cityName: cityName, areaName: areaName) {
            return area.zcId
        }
        return nil
    }
    
    // MARK: Network
    static func startNetworkMonitoring() {
        SystemManager.sharedInstance.networkManager?.startListening()
        SystemManager.sharedInstance.networkManager?.listener = { status in
            switch status {
            case .notReachable:
                if SystemManager.sharedInstance.networkStatus != .notReachable {
                    SystemManager.showNotReachableNetworkBanner()
                }
                break
            case .unknown:
                break
            case .reachable(.wwan):
                if SystemManager.sharedInstance.networkStatus == .notReachable {
                    SystemManager.showReachableNetworkBanner()
                    NotificationCenter.default.post(name: Notification.Name(DidRecoverConnection), object: nil)
                }
                break
            case .reachable(.ethernetOrWiFi):
                if SystemManager.sharedInstance.networkStatus == .notReachable {
                    SystemManager.showReachableNetworkBanner()
                    NotificationCenter.default.post(name: Notification.Name(DidRecoverConnection), object: nil)
                }
                break
            }
            SystemManager.sharedInstance.networkStatus = status
        }
    }
    
    static func isNetworkReachable(showBanner: Bool = true) -> Bool {
        if let net = SystemManager.sharedInstance.networkManager {
            if !net.isReachable && showBanner {
                SystemManager.showNotReachableNetworkBanner()
            }
            return net.isReachable
        }
        return false
    }
    
    // MARK: HUD
    static func showLoadingWithText(_ text: String) {
        HUD.show(.labeledProgress(title: nil, subtitle: text), onView: SystemManager.topViewController().view)
    }
    
    static func showLoading() {
        HUD.show(.labeledProgress(title: nil, subtitle: "Loading..."), onView: SystemManager.topViewController().view)
    }
    
    static func hideLoading() {
        HUD.hide()
    }
    
    static func endLoadingWith<T: Codable>(model: BaseModel<T>?, handler: actionClosure? = nil) {
        hideLoading()
        let alert = model?.sysmsg ?? LocalizedString("Lang_GE_014")
        let errorCode = (model?.sysmsg != nil) ? nil : "\(LocalizedString("Lang_GE_062")):9999"
        SystemManager.showAlertWith(alertTitle: alert, alertMessage: errorCode, buttonTitle: LocalizedString("Lang_GE_005"), handler: {
            if model?.syscode == 501 {
                if SystemManager.getAppIdentity() == .SalonWalker {
                    UserManager.sharedInstance.mId = nil
                    UserManager.deleteUserToken()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kAPISyscode_501), object: nil)
                    SystemManager.changeTabBarSelectIndex(index: 0, pop: true)
                } else {
                    SystemManager.backToLoginVC()
                }
            } else {
                handler?()
            }
        })
    }
    
    // MARK: Banner
    static func showReachableNetworkBanner() {
        SystemManager.showTipBannerWith(configureTheme: .success, title: LocalizedString("Lang_GE_013"), body: "", duration: 1.0)
    }
    
    static func showSuccessBanner(title: String, body: String) {
        SystemManager.showTipBannerWith(configureTheme: .success, title: title, body: body, duration: 1.0)
    }
    
    static func showErrorMessageBanner(title: String, body: String) {
        SystemManager.showTipBannerWith(configureTheme: .error, title: title, body: body, duration: 2.0)
    }
    
    static func showWarningBanner(title: String, body: String) {
        SystemManager.showTipBannerWith(configureTheme: .warning, title: title, body: body, duration: 2.0)
    }
    
    private static func showNotReachableNetworkBanner() {
        SystemManager.showTipBannerWith(configureTheme: .error, title: LocalizedString("Lang_GE_011"), body: LocalizedString("Lang_GE_012"), duration: 1.0)
    }
    
    private static func showTipBannerWith(configureTheme: Theme, title: String, body: String, duration: Double) {
        let deleyTime = (SwiftMessages.sharedInstance.current() != nil) ? 0.3 : 0.0
        SwiftMessages.hideAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + deleyTime) {
            var layout: MessageView.Layout = .messageViewIOS8
            if #available(iOS 9.0, *) {
                layout = .cardView
            }
            let view = MessageView.viewFromNib(layout: layout)
            view.configureTheme(configureTheme)
            view.configureDropShadow()
            view.configureContent(title: title, body: body)
            view.button?.isHidden = true
            var config = SwiftMessages.Config()
            config.presentationStyle = .top
            config.duration = .seconds(seconds: duration)
            config.interactiveHide = false
            SwiftMessages.show(config: config, view: view)
        }
    }
    
    // MARK: Alert
    static func showAlertWith(alertTitle: String?,
                              alertMessage: String?,
                              buttonTitle: String,
                              handler: actionClosure?) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let button = UIAlertAction(title: buttonTitle, style: .default) { action in
            DispatchQueue.main.async {
                handler?()
            }
        }
        alert.addAction(button)
        
        let vc = SystemManager.topViewController()
        if !vc.isBeingPresented && !vc.isBeingDismissed && !(vc.presentedViewController is UIAlertController) {
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    static func showAlertSheetWith(title: String?,
                                   message: String?,
                                   buttonTitles: [String],
                                   actions: [actionClosure?]) {
        if buttonTitles.count != actions.count {
            debugPrint("=== buttonTitles count is not equal actions count")
            return
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for i in 0..<buttonTitles.count {
            let buttonTitle = buttonTitles[i]
            let action = actions[i]
            let button = UIAlertAction(title: buttonTitle, style: .default, handler: { _ in
                DispatchQueue.main.async {
                    action?()
                }
            })
            alert.addAction(button)
        }
        let cancel = UIAlertAction(title: LocalizedString("Lang_GE_060"), style: .cancel, handler: nil)
        alert.addAction(cancel)
        let vc = SystemManager.topViewController()
        if !vc.isBeingPresented && !vc.isBeingDismissed && !(vc.presentedViewController is UIAlertController) {
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    static func showAlertSheetCustomActionWith(title: String?, message: String?, buttonTitles: [String], style: [UIAlertAction.Style], actions: [actionClosure?]) {
        if buttonTitles.count != actions.count || buttonTitles.count != style.count {
            debugPrint("=== buttonTitles count is not equal actions count")
            return
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for i in 0..<buttonTitles.count {
            let buttonTitle = buttonTitles[i]
            let action = actions[i]
            let button = UIAlertAction(title: buttonTitle, style: style[i], handler: { _ in
                DispatchQueue.main.async {
                    action?()
                }
            })
            alert.addAction(button)
        }
        let cancel = UIAlertAction(title: LocalizedString("Lang_GE_060"), style: .cancel, handler: nil)
        alert.addAction(cancel)
        let vc = SystemManager.topViewController()
        if !vc.isBeingPresented && !vc.isBeingDismissed && !(vc.presentedViewController is UIAlertController) {
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    static func showTwoButtonAlertWith(alertTitle: String?,
                                       alertMessage: String?,
                                       leftButtonTitle: String,
                                       rightButtonTitle: String,
                                       leftHandler: actionClosure?,
                                       rightHandler: actionClosure?) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let leftButton = UIAlertAction(title: leftButtonTitle, style: .default) { action in
            DispatchQueue.main.async {
                leftHandler?()
            }
        }
        let rightButton = UIAlertAction(title: rightButtonTitle, style: .default) { action in
            DispatchQueue.main.async {
                rightHandler?()
            }
        }
        alert.addAction(leftButton)
        alert.addAction(rightButton)
        
        let vc = SystemManager.topViewController()
        if !vc.isBeingPresented && !vc.isBeingDismissed && !(vc.presentedViewController is UIAlertController) {
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    static func showTextFieldAlertWith(title: String?,
                                       message: String?,
                                       buttonTitle: String,
                                       handler: ((String) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.textColor = .black
        }
        
        let button = UIAlertAction(title: buttonTitle, style: .default) { action in
            DispatchQueue.main.async {
                if let textField = alert.textFields?.first, let text = textField.text {
                    handler?(text)
                }
            }
        }
        alert.addAction(button)
        
        let vc = SystemManager.topViewController()
        if !vc.isBeingPresented && !vc.isBeingDismissed && !(vc.presentedViewController is UIAlertController) {
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    static func showErrorAlert(error: Error? = nil, backToLoginVC: Bool = false) {
        SystemManager.hideLoading()
        var errorCode: String?
        if let error = error {
            if let e = error as? AFError {
                switch e {
                case .invalidURL(let url):
                    print("Invalid URL: \(url) - \(e.localizedDescription)")
                    errorCode = "1001"
                    break
                case .parameterEncodingFailed(let reason):
                    print("Parameter encoding failed: \(e.localizedDescription)")
                    print("Failure Reason: \(reason)")
                    switch reason {
                    case .missingURL:
                        errorCode = "1002"
                        break
                    case .jsonEncodingFailed(let error):
                        print("Error: \(error.localizedDescription)")
                        errorCode = "1003"
                        break
                    case .propertyListEncodingFailed(let error):
                        print("Error: \(error.localizedDescription)")
                        errorCode = "1004"
                        break
                    }
                    break
                case .multipartEncodingFailed(let reason):
                    print("Multipart encoding failed: \(e.localizedDescription)")
                    print("Failure Reason: \(reason)")
                    switch reason {
                    case .bodyPartFileIsDirectory(let url):
                        print("URL: \(url)")
                        errorCode = "1005"
                        break
                    case .bodyPartURLInvalid(let url):
                        print("URL: \(url)")
                        errorCode = "1006"
                        break
                    case .bodyPartFilenameInvalid(let url):
                        print("URL: \(url)")
                        errorCode = "1007"
                        break
                    case .bodyPartFileNotReachable(let url):
                        print("URL: \(url)")
                        errorCode = "1008"
                        break
                    case .bodyPartFileNotReachableWithError(let url, let error):
                        print("URL: \(url)")
                        print("Error: \(error.localizedDescription)")
                        errorCode = "1009"
                        break
                    case .bodyPartFileSizeNotAvailable(let url):
                        print("URL: \(url)")
                        errorCode = "1010"
                        break
                    case .bodyPartFileSizeQueryFailedWithError(let url, let error):
                        print("URL: \(url)")
                        print("Error: \(error.localizedDescription)")
                        errorCode = "1011"
                        break
                    case .bodyPartInputStreamCreationFailed(let url):
                        print("URL: \(url)")
                        errorCode = "1012"
                        break
                    case .outputStreamCreationFailed(let url):
                        print("URL: \(url)")
                        errorCode = "1013"
                        break
                    case .outputStreamFileAlreadyExists(let url):
                        print("URL: \(url)")
                        errorCode = "1014"
                        break
                    case .outputStreamURLInvalid(let url):
                        print("URL: \(url)")
                        errorCode = "1015"
                        break
                    case .outputStreamWriteFailed(let error):
                        print("Error: \(error.localizedDescription)")
                        errorCode = "1016"
                        break
                    case .inputStreamReadFailed(let error):
                        print("Error: \(error.localizedDescription)")
                        errorCode = "1017"
                        break
                    }
                    break
                case .responseValidationFailed(let reason):
                    print("Response validation failed: \(e.localizedDescription)")
                    
                    switch reason {
                    case .dataFileNil, .dataFileReadFailed:
                        print("Downloaded file could not be read")
                        errorCode = "1018"
                        break
                    case .missingContentType(let acceptableContentTypes):
                        print("Content Type Missing: \(acceptableContentTypes)")
                        errorCode = "1019"
                        break
                    case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                        print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                        errorCode = "1020"
                        break
                    case .unacceptableStatusCode(let code):
                        print("Response status code was unacceptable: \(code)")
                        errorCode = "1021(\(code))"
                        break
                    }
                    break
                case .responseSerializationFailed(let reason):
                    print("Response serialization failed: \(e.localizedDescription)")
                    print("Failure Reason: \(reason)")
                    switch reason {
                    case .inputDataNil:
                        errorCode = "1022"
                        break
                    case .inputDataNilOrZeroLength:
                        errorCode = "1023"
                        break
                    case .inputFileNil:
                        errorCode = "1024"
                        break
                    case .inputFileReadFailed(let url):
                        print("URL: \(url)")
                        errorCode = "1025"
                        break
                    case .stringSerializationFailed(let encoding):
                        print("Encoding: \(encoding)")
                        errorCode = "1026"
                        break
                    case .jsonSerializationFailed(let error):
                        print("Error: \(error.localizedDescription)")
                        errorCode = "1027"
                        break
                    case .propertyListSerializationFailed(let error):
                        print("Error: \(error.localizedDescription)")
                        errorCode = "1028"
                        break
                    }
                    break
                }
                print("Underlying error: \(String(describing: e.underlyingError))")
            } else if let e = error as? URLError {
                /* -1005參考：
                https://stackoverflow.com/a/25996971/7103908
                http://blog.harrisonxi.com/2017/03/NSURLErrorDomain%E7%9A%84-1005%E9%94%99%E8%AF%AF.html
                https://developer.apple.com/documentation/cfnetwork/cfnetworkerrors
                */
                errorCode = "2001(\(e._code))"
                print("URLError occurred: \(e)")
            } else {
                errorCode = "3001(\(error._code))"
                print("Unknown error: \(error)")
            }
        }
        
        DispatchQueue.main.async {
            let alertMessage = (errorCode != nil) ? "\(LocalizedString("Lang_GE_062")):\(errorCode!)" : nil
            SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_GE_014"), alertMessage: alertMessage, buttonTitle: LocalizedString("Lang_GE_005"), handler: {
                if backToLoginVC {
                    SystemManager.backToLoginVC()
                }
            })
        }
    }
    
    static func showTimeOutErrorAlert(tryAgainHandler: @escaping actionClosure) {
        SystemManager.hideLoading()
        SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_GE_015"), alertMessage: LocalizedString("Lang_GE_012"), buttonTitle: LocalizedString("Lang_GE_016"), handler: {
            SystemManager.showLoading()
            tryAgainHandler()
        })
    }
    
    static func showMustLoginAlert() {
        PresentationTool.showTwoButtonAlertWith(image: UIImage(named: "img_member"), message: LocalizedString("Lang_GE_064"), leftButtonTitle: LocalizedString("Lang_GE_066"), leftButtonAction: nil, rightButtonTitle: LocalizedString("Lang_GE_065"), rightButtonAction: {
            let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: String(describing: LoginViewController.self)) as! LoginViewController
            let naviVC = UINavigationController(rootViewController: vc)
            naviVC.isNavigationBarHidden = true
            SystemManager.topViewController().present(naviVC, animated: true, completion: nil)
        })
    }
    
    // MARK: Share
    /** 分享功能，共三種：文字、照片，影片；PS excludedType 指，不要能被分享的項目 */
    static func goingToShareInfoAbout(text: String? = nil, images: [UIImage]? = nil, video: AVAsset? = nil, excludedType: [UIActivity.ActivityType]? = nil) {
        
        SystemManager.showLoading()
        
        var array = [Any]()
        if let text = text {
            array.append(text)
        }
        if let images = images {
            array.append(contentsOf: images)
        }
        if let video = video {
            // AVAsset is an abstract class, so when you create an asset as shown in the example, you’re actually creating an instance of one of its concrete subclasses called AVURLAsset
            let url = video as! AVURLAsset
            array.append(url.url)
        }
        if array.count > 0 {
            DispatchQueue.main.async {
                let activityViewController = UIActivityViewController(activityItems: array, applicationActivities: nil)
                let vc = SystemManager.topViewController()
                activityViewController.popoverPresentationController?.sourceView = vc.view
                if let excludedArray = excludedType {
                    activityViewController.excludedActivityTypes = excludedArray
                }
                if !vc.isBeingPresented && !vc.isBeingDismissed {
                    vc.present(activityViewController, animated: true, completion: {
                        SystemManager.hideLoading()
                    })
                }
            }
        } else {
            SystemManager.hideLoading()
        }
    }
    
    static func openSalonWalkerFB() {
        let appUrl = URL(string: "fb://profile/307361443206419")!
        let webUrl = URL(string: "https://www.facebook.com/salonwalker/")!
        
        if #available(iOS 10.0, *) {
            if UIApplication.shared.canOpenURL(appUrl) {
                UIApplication.shared.open(appUrl, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
            }
        } else {
            if UIApplication.shared.canOpenURL(appUrl) {
                UIApplication.shared.openURL(appUrl)
            } else {
                UIApplication.shared.openURL(webUrl)
            }
        }
    }
    
    static func openSalonWalkerIG() {
        let appUrl = URL(string: "instagram://user?username=salonwalker")!
        let webUrl = URL(string: "https://www.instagram.com/salonwalker/")!
        
        if #available(iOS 10.0, *) {
            if UIApplication.shared.canOpenURL(appUrl) {
                UIApplication.shared.open(appUrl, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
            }
        } else {
            if UIApplication.shared.canOpenURL(appUrl) {
                UIApplication.shared.openURL(appUrl)
            } else {
                UIApplication.shared.openURL(webUrl)
            }
        }
    }
    
    // MARK: DeepLink
    static func setDeepLinkInfo(info: [AnyHashable : Any]) {
        SystemManager.sharedInstance.deepLinkInfo = info
    }
    
    static func handleDeepLink() {
        if SystemManager.topViewController() is LoginViewController { return }
        if let info = SystemManager.sharedInstance.deepLinkInfo {
            if info["seArticlesId"] != nil || info["maArticleId"] != nil {
                let seArticlesId = info["seArticlesId"] as? Int
                let maArticleId = info["maArticleId"] as? Int
                if SystemManager.topViewController() is WebViewController {
                    (SystemManager.topViewController() as! WebViewController).reloadWebViewWith(seArticlesId: seArticlesId, maArticleId: maArticleId)
                } else {
                    let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: WebViewController.self)) as! WebViewController
                    vc.setupWebVCWith(seArticlesId: seArticlesId, maArticleId: maArticleId)
                    SystemManager.topViewController().navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                if let dId = info["dId"] as? Int {
                    if SystemManager.topViewController() is DesignerDetailViewController {
                        (SystemManager.topViewController() as! DesignerDetailViewController).resetDataByBranch(dId:dId)
                    } else {
                        let vc = UIStoryboard(name: kStory_DesignerDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: DesignerDetailViewController.self)) as! DesignerDetailViewController
                        vc.setupVCWith(dId: dId)
                        
                        SystemManager.topViewController().navigationController?.pushViewController(vc, animated: true)
                    }
                } else if let pId = info["pId"] as? Int {
                    if SystemManager.topViewController() is StoreDetailViewController {
                        (SystemManager.topViewController() as! StoreDetailViewController).resetDataByBranch(pId:pId)
                    } else {
                        let vc = UIStoryboard(name: kStory_StoreDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: StoreDetailViewController.self)) as! StoreDetailViewController
                        vc.setupVCWith(pId: pId, type: .canBook)
                        SystemManager.topViewController().navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            SystemManager.sharedInstance.deepLinkInfo = nil
        }
    }
    
    // MARK: TabBar Select Index
    static func changeTabBarSelectIndex(index: Int, pop: Bool = false) {
        if SystemManager.getAppIdentity() == .SalonWalker {
            let tabVC = UIApplication.shared.delegate?.window??.rootViewController as? MainTabBarController
            if pop {
                if let index = tabVC?.selectedIndex, let naviVC = tabVC?.viewControllers?[index] as? UINavigationController {
                    naviVC.popToRootViewController(animated: true)
                }
            }
            tabVC?.customTabBar.selectIndex = index
            tabVC?.selectedIndex = index
        } else {
            let naviVC = UIApplication.shared.delegate?.window??.rootViewController as? UINavigationController
            if pop {
                naviVC?.popToRootViewController(animated: true)
            }
            let tabVC = naviVC?.visibleViewController as? MainTabBarController
            tabVC?.customTabBar.selectIndex = index
            tabVC?.selectedIndex = index
        }
    }
    
    // MARK: Terms of Service
    static func openServiceTerms() {
        var url = ""
        #if DEV
        url = "http://salonwalker-tst.skywind.com.tw:8025/admin/registerClause/appIndex?type="
        #else
        url = "http://137.116.133.132/admin/registerClause/appIndex?type="
        #endif
        switch UserManager.sharedInstance.userIdentity {
        case .consumer?:
            url += "M"
            break
        case .designer?:
            url += "D"
            break
        case .store?:
            url += "P"
            break
        default: return
        }
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.setupWebVCWith(url: url)
        SystemManager.topViewController().navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Terms of the transaction
    static func openTransactionTerms() {
        var url = ""
        #if DEV
        url = "http://salonwalker-tst.skywind.com.tw:8025/admin/transactionClause/appIndex?type="
        #else
        url = "http://137.116.133.132/admin/transactionClause/appIndex?type="
        #endif
        switch UserManager.sharedInstance.userIdentity {
        case .consumer?:
            url += "M"
            break
        case .designer?:
            url += "D"
            break
        case .store?:
            url += "P"
            break
        default: return
        }
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.setupWebVCWith(url: url)
        SystemManager.topViewController().navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: TopViewController
    static func topViewController() -> UIViewController {
        var vc = UIApplication.shared.keyWindow?.rootViewController
        
        if vc == nil, let window = UIApplication.shared.delegate?.window {
            vc = window?.rootViewController
        }
        
        guard vc != nil else {
            debugPrint("could not found topViewController")
            return UIViewController()
        }
        
        if vc!.isKind(of: UINavigationController.self), let naviVC = vc as? UINavigationController {
            vc = naviVC.visibleViewController
        }
        
        if vc!.isKind(of: UITabBarController.self), let tabVC = vc as? UITabBarController {
            vc = tabVC.selectedViewController
        }
        
        if vc!.isKind(of: UINavigationController.self), let naviVC = vc as? UINavigationController {
            vc = naviVC.visibleViewController
        }
        
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }
        
        if vc!.isKind(of: UIAlertController.self) {
            vc = vc?.presentingViewController
        }
        
        return vc!
    }
    
    static func backToLoginVC() {
        var vc: UIViewController? = SystemManager.topViewController()
        while vc?.presentingViewController != nil {
            vc = vc?.presentingViewController
        }
        vc?.navigationController?.popToRootViewController(animated: false)
        vc?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: API
    /// S001 取得版號
    static func apiGetVersion(success: @escaping (_ response: BaseModel<VersionModel>?) -> Void,
                              failure: @escaping failureClosure) {
        let appType = (SystemManager.getAppIdentity() == .SalonWalker) ? "member" : "dealer"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let parameters = ["device":"ios",
                          "appType":appType,
                          "deviceVersion":appVersion]
        APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.System.version, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<VersionModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// S002 新增、編輯及刪除暫存圖片
    static func apiTempImage(imageType: String,
                             image: String?,
                             fbImgUrl: String?,
                             googleImgUrl: String?,
                             tempImgId:[Int]?,
                             mId: Int?,
                             ouId: Int?,
                             licenseImgId: Int?,
                             coverImgId: Int?,
                             act: String,
                             success: @escaping (_ response: BaseModel<TempImageModel>?) -> Void,
                             failure: @escaping failureClosure) {
        var parameters: [String:Any] = ["imageType":imageType,
                                        "act":act]
        if let image = image {
            parameters["image"] = image
        }
        if let fbImgUrl = fbImgUrl {
            parameters["fbImgUrl"] = fbImgUrl
        }
        if let googleImgUrl = googleImgUrl {
            parameters["googleImgUrl"] = googleImgUrl
        }
        if let tempImgId = tempImgId {
            parameters["tempImgId"] = tempImgId
        }
        if let mId = mId {
            parameters["mId"] = mId
        }
        if let ouId = ouId {
            parameters["ouId"] = ouId
        }
        if let licenseImgId = licenseImgId {
            parameters["licenseImgId"] = licenseImgId
        }
        if let coverImgId = coverImgId {
            parameters["coverImgId"] = coverImgId
        }
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.System.tempImage, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<TempImageModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// S003 取得手機國際區碼
    static func apiGetPhoneCode(success: @escaping (_ response: BaseModel<[PhoneCodeModel]>?) -> Void,
                                failure: @escaping failureClosure) {
        APIManager.sendGetRequestWith(parameters: nil, path: ApiUrl.System.getPhoneCode, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<[PhoneCodeModel]>.self)
            success(result)
        }, failure: failure)
    }
    
    /// S004 取得語系列表
    static func apiGetSystemLang(success: @escaping (_ response: BaseModel<SystemLangModel>?) -> Void,
                                 failure: @escaping failureClosure) {
        APIManager.sendGetRequestWith(parameters: nil, path: ApiUrl.System.getSystemLang, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<SystemLangModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// S005 取得縣市區域列表
    static func apiGetCityCode(success: @escaping (_ response: BaseModel<CityCodeModel>?) -> Void,
                               failure: @escaping failureClosure) {
        APIManager.sendGetRequestWith(parameters: nil, path: ApiUrl.System.getCityCode, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<CityCodeModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// S006 新增、編輯產品圖片
    static func apiProductTempImage(image: String?,
                                    dscild: Int?,
                                    brand: String?,
                                    product: String?,
                                    act: String,
                                    success: @escaping (_ response: BaseModel<SvcProductModel>?) -> Void,
                                    failure: @escaping failureClosure) {
        var parameters: [String: Any] = ["act": act]
        if let image = image {
            parameters["image"] = image
        }
        if let dscild = dscild {
            parameters["dscild"] = dscild
        }
        if let brand = brand {
            parameters["brand"] = brand
        }
        if let product = product {
            parameters["product"] = product
        }
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.System.productTempImage, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<SvcProductModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// S007 取得服務條款
    static func apiGetSvcClause(success: @escaping (_ response: BaseModel<SvcClauseModel>?) -> Void,
                                failure: @escaping failureClosure) {
        var type = ""
        if UserManager.sharedInstance.userIdentity == .consumer {
            type = "M"
        } else if UserManager.sharedInstance.userIdentity == .designer {
            type = "D"
        } else if UserManager.sharedInstance.userIdentity == .store {
            type = "P"
        }
        APIManager.sendGetRequestWith(parameters: ["type":type], path: ApiUrl.System.getSvcClause, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<SvcClauseModel>.self)
            success(result)
        }, failure: failure)
    }

//    /// S008 新增、編輯及刪除暫存圖片 - 作品集 / 場地照
      // 刪除暫存圖片功能，原圖片新增功能使用W009,W010,W012/編輯 W011, W013/刪除W014,W015,W016
//    static func apiWorksTempPhotos(uploadFile: String?,
//                                   fileExtension: String?,
//                                   dwpId: [Int]?,
//                                   dwaId: [Int]?,
//                                   dwvId: [Int]?,
//                                   pppId: [Int]?,
//                                   ppvId: [Int]?,
//                                   ppapId: [Int]?,
//                                   act: String,
//                                   success: @escaping (_ response: BaseModel<WorksTempPhotosModel>?) -> Void,
//                                   failure: @escaping failureClosure) {
//        var parameters: [String: Any] = ["act": act]
//        if let uploadFile = uploadFile {
//            parameters["uploadFile"] = uploadFile
//        }
//        if let fileExtension = fileExtension {
//            parameters["fileExtension"] = fileExtension
//        }
//        if let dwpId = dwpId {
//            parameters["dwpId"] = dwpId
//        }
//        if let dwapId = dwaId {
//            parameters["dwapId"] = dwapId
//        }
//        if let dwvId = dwvId {
//            parameters["dwvId"] = dwvId
//        }
//        if let pppId = pppId {
//            parameters["pppId"] = pppId
//        }
//        if let ppvId = ppvId {
//            parameters["ppvId"] = ppvId
//        }
//        if let ppapId = ppapId {
//            parameters["ppapId"] = ppapId
//        }
//
//        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.System.worksTempPhotos, success: { (response) in
//            let result = APIManager.decode(response: response, type: BaseModel<WorksTempPhotosModel>.self)
//            success(result)
//        }, failure: failure)
//    }
    
    /// S009 新增、刪除範例圖片
    static func apiOrderPhotoTempImage(image: String?,
                                       rpId: [Int]?,
                                       oepId: Int?,
                                       act: String,
                                       success: @escaping (_ response: BaseModel<[TempImageModel]>?) -> Void,
                                       failure: @escaping failureClosure) {
        var parameters: [String:Any] = ["act":act]
        if let image = image {
            parameters["image"] = image
        }
        if let rpId = rpId {
            parameters["rpId"] = rpId
        }
        if let oepId = oepId {
            parameters["oepId"] = oepId
        }
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.System.orderPhotoTempImage, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<OrderPhotoModel>.self)
            let model = BaseModel(syscode: result?.syscode ?? 0, sysmsg: result?.sysmsg ?? "", data: result?.data?.orderPhoto)
            success(model)
        }, failure: failure)
    }
    
    /// S010 取得檢舉原因
    static func apiGetReportedReason(type: String,
                                     success: @escaping (_ response: BaseModel<ReportedReasonModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        APIManager.sendGetRequestWith(parameters: ["type":type], path: ApiUrl.System.getReportedReason, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<ReportedReasonModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// S011 取得意見回饋標籤
    static func apiGetFeedbackLabel(success: @escaping (_ response: BaseModel<FeedbackModel>?) -> Void,
                                    failure: @escaping failureClosure) {
        var type = ""
        if UserManager.sharedInstance.userIdentity == .consumer {
            type = "M"
        } else if UserManager.sharedInstance.userIdentity == .designer {
            type = "D"
        } else {
            type = "P"
        }
        APIManager.sendGetRequestWith(parameters: ["type":type], path: ApiUrl.System.getFeedbackLabel, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<FeedbackModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// S012 上傳意見回饋圖檔
    static func apiUploadFeedbackPhoto(image: String,
                                       success: @escaping (_ response: BaseModel<TempImageModel>?) -> Void,
                                       failure: @escaping failureClosure) {
        var parameters: [String:Any] = ["image":image]
        if let mId = UserManager.sharedInstance.mId {
            parameters["mId"] = mId
        } else if let ouId = UserManager.sharedInstance.ouId {
            parameters["ouId"] = ouId
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
            return
        }
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.System.uploadPhoto, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<TempImageModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// S013 送出意見回饋
    static func apiGiveFeedback(flId: Int,
                                email: String,
                                content: String,
                                fiId: [Int]?,
                                success: @escaping (_ response: BaseModel<UpdateUserDataModel>?) -> Void,
                                failure: @escaping failureClosure) {
        var parameters: [String:Any] = ["flId":flId,"email":email,"content":content]
        if let fiId = fiId {
            parameters["fiId"] = fiId
        }
        if let mId = UserManager.sharedInstance.mId {
            parameters["mId"] = mId
        } else if let ouId = UserManager.sharedInstance.ouId {
            parameters["ouId"] = ouId
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
            return
        }
        APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.System.giveFeedback, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<UpdateUserDataModel>.self)
            success(result)
        }, failure: failure)
    }
}


