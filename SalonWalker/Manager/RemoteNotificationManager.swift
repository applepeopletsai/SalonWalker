//
//  RemoteNotificationManager.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/18.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
/*
 推播格式範例：
 {
    "order":
            {
                "notifyId": 20180731095401,
                "alertType": "100",
                "moId": 12
                "doId": 0,
                "alertMsg": ""
            },
    "infoData": null
 }
 
 參數說明：
 order.notifyId     (Int)       通知流水號，訊息息編碼:yyyyMMddhhiiss
 order.alertType    (String)    通知種類
 order.moId         (Int)       消費者訂單代號
 order.doId         (Int)       設計師訂單代號
 order.alertMsg     (String)    APP需顯示的通知文字(如無須顯示則給空字串)
 infoData.notifyId  (Int)       通知流水號，訊息息編碼:yyyyMMddhhiiss
 infoData.nmId      (Int)       最新消息ID
 infoData.alertType (String)    通知種類 (預設100)
 
 order.alertType說明：
 100    不顯示按鈕，跳轉到指定訂單詳細頁
 200    消費者取消設計師訂單，設計師決定是否與場地訂單一起取消
 201    後台人員取消設計師訂單，設計師決定是否將客戶訂單一起取消
 300    設計師更新服務總價，告知消費者已更新價格
 301    場地更新租金總價，告知設計師已更新價格
 400    消費者支付尾款，設計師收到尾款通知
 401    設計師支付尾款，場地收到尾款通知
 
 infoData.alertType說明：
 900    開啟APP
 901    開啟APP，跳轉到 業者/場地 詳細頁
 902    開啟APP，跳轉到 設計師 詳細頁
 
 推播情境：
 [消費者訂單]
 情境                     接收者              order.alertType
 消費者支付訂金成功          設計師              100
 消費者取消訂單             設計師              待回覆:100, 已回覆:200
 設計師取消消費者訂單        消費者              100
 消費者打卡通知(簽到)        設計師              100
 設計師打卡通知(簽到)        消費者              100
 設計師打卡通知(簽退)        場地                100
 消費者訂單服務金額已更新     消費者               300
 消費者尾款支付通知          設計師               400
 設計師回覆消費者訂單         消費者              100
 設計師未回覆30分鐘自動取消   消費者               100
 服務前3小時提醒            消費者/設計師         100
 服務開始前30分鐘           消費者/設計師         100
 
 [設計師訂單]
 情境                     接收者              order.alertType
 設計師支付訂金成功          場地                100
 設計師取消設計師訂單        場地                100
 後台取消設計師訂單          設計師              201
 設計師訂單租金金額已更新     設計師               301
 設計師尾款支付通知          場地                401
 服務前3小時提醒            設計師               100
 服務開始前30分鐘           設計師               100
 */

class RemoteNotificationManager: NSObject {

    static func handleRemoteNotification() {
        if SystemManager.topViewController() is LoginViewController { return }
        if let data = UserManager.sharedInstance.remoteNotificationUserInfo {
            guard let userIdentity = UserManager.sharedInstance.userIdentity, let alertType = data["alertType"] as? String else {
                UserManager.sharedInstance.remoteNotificationUserInfo = nil
                return
            }
            
            switch userIdentity {
            case .consumer:
                switch alertType {
                case "100","300":
                    goToConsumerOrderDetailByC(type: alertType)
                    break
                case "902":
                    gotoDesignerDetilVC()
                    break
                default:break
                }
                break
            case .designer:
                switch alertType {
                case "100":
                    if UserManager.sharedInstance.remoteNotificationUserInfo?["moId"] != nil {
                        goToConsumerOrderDetailByD(type: alertType)
                    } else if UserManager.sharedInstance.remoteNotificationUserInfo?["doId"] != nil {
                        gotoSiteOrderDetailByD(type: alertType)
                    }
                    break
                case "200","400":
                    goToConsumerOrderDetailByD(type: alertType)
                    break
                case "201","301":
                    gotoSiteOrderDetailByD(type: alertType)
                    break
                case "901":
                    gotoStoreDetailVC()
                    break
                default: break
                }
                break
            case .store:
                switch alertType {
                case "401":
                    gotoSiteOrderDetailByS()
                    break
                default: break
                }
                break
            }
            UserManager.sharedInstance.remoteNotificationUserInfo = nil
        }
    }
    
    private static func goToConsumerOrderDetailByC(type: String) {
        #if SALONWALKER
        guard let moId = UserManager.sharedInstance.remoteNotificationUserInfo?["moId"] as? Int else { return }
        if SystemManager.topViewController() is ConsumerReservationDetailViewController {
            (SystemManager.topViewController() as! ConsumerReservationDetailViewController).resetDataByRemoteNotification(moId: moId)
        } else {
            let vc = UIStoryboard(name: kStory_ReserveDesigner, bundle: nil).instantiateViewController(withIdentifier: String(describing: ConsumerReservationDetailViewController.self)) as!ConsumerReservationDetailViewController
            vc.setupVCWith(moId: moId)
            
            switch type {
            case "100":
                SystemManager.topViewController().navigationController?.pushViewController(vc, animated: true)
                break
            case "300":
                if let alertMsg = UserManager.sharedInstance.remoteNotificationUserInfo?["alertMsg"] as? String {
                    PresentationTool.showTwoButtonAlertWith(image: UIImage(named: "img_items"), message: alertMsg, leftButtonTitle: LocalizedString("Lang_GE_057"), leftButtonAction: nil, rightButtonTitle: LocalizedString("Lang_SD_028"), rightButtonAction: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                            // topViewController此時還是PresentationTool中的controller，故延遲push
                            SystemManager.topViewController().navigationController?.pushViewController(vc, animated: true)
                        })
                    })
                } else {
                    SystemManager.topViewController().navigationController?.pushViewController(vc, animated: true)
                }
                break
            default: break
            }
        }
        #endif
    }
    
    private static func goToConsumerOrderDetailByD(type: String) {
        #if SALONMAKER
        guard let moId = UserManager.sharedInstance.remoteNotificationUserInfo?["moId"] as? Int else { return }
        
        if SystemManager.topViewController() is DesignerReservationByConsumerDetailViewController {
            switch type {
            case "100":
                (SystemManager.topViewController() as! DesignerReservationByConsumerDetailViewController).resetDataByRemoteNotification(moId: moId)
                break
            case "200", "400":
                guard let doId = UserManager.sharedInstance.remoteNotificationUserInfo?["doId"] as? Int else { return }
                if let alertMsg = UserManager.sharedInstance.remoteNotificationUserInfo?["alertMsg"] as? String {
                    (SystemManager.topViewController() as! DesignerReservationByConsumerDetailViewController).resetDataByRemoteNotification(moId: moId, bindDoId: doId, remoteNotifyMsg: alertMsg, alertType: type)
                } else {
                    (SystemManager.topViewController() as! DesignerReservationByConsumerDetailViewController).resetDataByRemoteNotification(moId: moId, bindDoId: doId)
                }
                break
            default: break
            }
        } else {
            let vc = UIStoryboard(name: "OrderRecord", bundle: nil).instantiateViewController(withIdentifier: String(describing: DesignerReservationByConsumerDetailViewController.self)) as! DesignerReservationByConsumerDetailViewController
            switch type {
            case "100":
                vc.setupVCWith(moId: moId)
                break
            case "200", "400":
                guard let doId = UserManager.sharedInstance.remoteNotificationUserInfo?["doId"] as? Int else { return }
                if let alertMsg = UserManager.sharedInstance.remoteNotificationUserInfo?["alertMsg"] as? String {
                    vc.setupVCWith(moId: moId, bindDoId: doId, remoteNotifyMsg: alertMsg, alertType: type)
                } else {
                    vc.setupVCWith(moId: moId, bindDoId: doId)
                }
                break
            default: return
            }
            SystemManager.topViewController().navigationController?.pushViewController(vc, animated: true)
        }
        #endif
    }
    
    private static func gotoSiteOrderDetailByD(type: String) {
        #if SALONMAKER
        guard let doId = UserManager.sharedInstance.remoteNotificationUserInfo?["doId"] as? Int else { return }
        if SystemManager.topViewController() is OperatingReservationDetailViewController {
            switch type {
            case "201":
                guard let alertMsg = UserManager.sharedInstance.remoteNotificationUserInfo?["alertMsg"] as? String, let bindMoId = UserManager.sharedInstance.remoteNotificationUserInfo?["moId"] as? Int else { return }
                (SystemManager.topViewController() as! OperatingReservationDetailViewController).resetDataByRemoteNotification(doId: doId, bindMoId: bindMoId, remoteNotifyMsg: alertMsg, alertType: type)
                break
            case "100","301":
                (SystemManager.topViewController() as! OperatingReservationDetailViewController).resetDataByRemoteNotification(doId: doId)
                break
            default: break
            }
        } else {
            let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: OperatingReservationDetailViewController.self)) as! OperatingReservationDetailViewController
            
            switch type {
            case "100":
                vc.setupVCWith(doId: doId, orderDetailInfoModel: nil)
                SystemManager.topViewController().navigationController?.pushViewController(vc, animated: true)
                break
            case "201":
                guard let alertMsg = UserManager.sharedInstance.remoteNotificationUserInfo?["alertMsg"] as? String, let bindMoId = UserManager.sharedInstance.remoteNotificationUserInfo?["moId"] as? Int else { return }
                vc.setupVCWith(doId: doId, bindMoId: bindMoId, orderDetailInfoModel: nil, remoteNotifyMsg: alertMsg, alertType: type)
                SystemManager.topViewController().navigationController?.pushViewController(vc, animated: true)
                break
            case "301":
                guard let alertMsg = UserManager.sharedInstance.remoteNotificationUserInfo?["alertMsg"] as? String else { return }
                vc.setupVCWith(doId: doId, orderDetailInfoModel: nil)
                PresentationTool.showTwoButtonAlertWith(image: UIImage(named: "img_pop_barbershop"), message: alertMsg, leftButtonTitle: LocalizedString("Lang_GE_057"), leftButtonAction: nil, rightButtonTitle: LocalizedString("Lang_SD_028"), rightButtonAction: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                        // topViewController此時還是PresentationTool中的controller，故延遲push
                        SystemManager.topViewController().navigationController?.pushViewController(vc, animated: true)
                    })
                })
                break
            default: break
            }
        }
        #endif
    }
    
    private static func gotoSiteOrderDetailByS() {
        #if SALONMAKER
        guard let doId = UserManager.sharedInstance.remoteNotificationUserInfo?["doId"] as? Int, let alertMsg = UserManager.sharedInstance.remoteNotificationUserInfo?["alertMsg"] as? String else { return }
        if SystemManager.topViewController() is OperatingReservationDetailViewController {
            (SystemManager.topViewController() as! OperatingReservationDetailViewController).resetDataByRemoteNotification(doId: doId, remoteNotifyMsg: alertMsg)
        } else {
            let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: OperatingReservationDetailViewController.self)) as! OperatingReservationDetailViewController
            vc.setupVCWith(doId: doId, orderDetailInfoModel: nil, remoteNotifyMsg: alertMsg)
            SystemManager.topViewController().navigationController?.pushViewController(vc, animated: true)
        }
        #endif
    }
    
    private static func gotoStoreDetailVC() {
        guard let pId = UserManager.sharedInstance.remoteNotificationUserInfo?["pId"] as? Int else { return }
        if SystemManager.topViewController() is StoreDetailViewController {
            (SystemManager.topViewController() as! StoreDetailViewController).resetDataByRemoteNotification(pId: pId)
        } else {
            let vc = UIStoryboard(name: kStory_StoreDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: StoreDetailViewController.self)) as! StoreDetailViewController
            vc.setupVCWith(pId: pId, type: .canBook)
            SystemManager.topViewController().navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private static func gotoDesignerDetilVC() {
        guard let dId = UserManager.sharedInstance.remoteNotificationUserInfo?["dId"] as? Int else { return }
        
        if SystemManager.topViewController() is DesignerDetailViewController {
            (SystemManager.topViewController() as! DesignerDetailViewController).resetDataByRemoteNotification(dId: dId)
        } else {
            let vc = UIStoryboard(name: kStory_DesignerDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: DesignerDetailViewController.self)) as! DesignerDetailViewController
            vc.setupVCWith(dId: dId)
            SystemManager.topViewController().navigationController?.pushViewController(vc, animated: true)
        }
    }
}
