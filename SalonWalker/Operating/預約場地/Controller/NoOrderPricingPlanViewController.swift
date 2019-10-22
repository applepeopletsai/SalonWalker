//
//  NoOrderPricingPlanViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum ShowPaySchemeType {
    case choose         // 選擇計價方案
    case check          // 查看計價方案
}

// 純預約場地(設計師直接預約場地)
class NoOrderPricingPlanViewController: BaseViewController {

    @IBOutlet private weak var naviTitleLabel: UILabel!
    @IBOutlet private weak var typeTitleLabel: IBInspectableLabel!
    @IBOutlet private weak var hoursViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var timesViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var longLeaseViewHeight: NSLayoutConstraint!
    
    private var showSchemeType: ShowPaySchemeType = .choose
    private var svcPricesModel: SvcPricesModel?
    private var orderDetailInfoModel: OrderDetailInfoModel?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    // MARK: Method
    override func networkDidRecover() {
        callAPI()
    }
    
    func setupVCWith(model: OrderDetailInfoModel?, type: ShowPaySchemeType) {
        self.orderDetailInfoModel = model
        self.showSchemeType = type
    }
    
    private func initialize() {
        naviTitleLabel.text = orderDetailInfoModel?.provider?.nickName
        typeTitleLabel.text = (showSchemeType == .check) ? LocalizedString("Lang_PS_001") : LocalizedString("Lang_RD_028")
    }
    
    private func setupUI() {
        self.hoursViewHeight.constant = (svcPricesModel?.svcHours?.svcHoursPrices != nil) ? 60 : 0
        self.timesViewHeight.constant = (svcPricesModel?.svcTimes?.svcTimesPrices != nil) ? 60 : 0
        self.longLeaseViewHeight.constant = (svcPricesModel?.svcLongLease?.purchasedItems != nil ||
            svcPricesModel?.svcLongLease?.notPurchased != nil) ? 60 : 0
    }
    
    private func callAPI() {
        if svcPricesModel == nil {
            apiGetSvcPrices()
        }
    }
    
    // MARK: Event Handler
    @IBAction func hourButtonClick(_ sender: UIButton) {
        if let array = svcPricesModel?.svcHours?.svcHoursPrices {
            let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: HourAndTimeSchemeViewController.self)) as! HourAndTimeSchemeViewController
            vc.setupVCWith(dataArray: array, showSchemeType: showSchemeType, chooseSchemeType: .hour, delegate: self)
            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func timesButtonClick(_ sender: UIButton) {
        if let array = svcPricesModel?.svcTimes?.svcTimesPrices {
            let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: HourAndTimeSchemeViewController.self)) as! HourAndTimeSchemeViewController
            vc.setupVCWith(dataArray: array, showSchemeType: showSchemeType, chooseSchemeType: .times, delegate: self)
            present(vc, animated: true, completion: nil)
        }
    }
 
    @IBAction func longRentButtonClick(_ sender: UIButton) {
        if let model = svcPricesModel?.svcLongLease {
            let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: RentSchemeViewController.self)) as! RentSchemeViewController
            vc.setupVCWith(model: model, showSchemeType: showSchemeType, chooseSchemeType: .longRent, delegate: self)
            present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: API
    private func apiGetSvcPrices() {
        guard let pId = orderDetailInfoModel?.provider?.pId else { return }
        if SystemManager.isNetworkReachable() {
            
            self.showLoading()
            ReservationManager.apiGetSvcPrices(pId: pId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.svcPricesModel = model?.data
                    self.setupUI()
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
                self.removeMaskView()
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

/*
 orderType(訂單類別)：
 1:小時方案
 2:次數方案
 3:長租方案 (購買)
 4:長租方案 (使用)
 */
extension NoOrderPricingPlanViewController: HourAndTimeSchemeViewControllerDelegate {
    func confirmButtonPressWith(model: Codable, type: PaySchemeType) {
        if model is HoursAndTimesPricesModel {
            orderDetailInfoModel?.svcHoursPrices = nil
            orderDetailInfoModel?.svcTimesPrices = nil
            orderDetailInfoModel?.svcLongLeasePrices = nil
            if type == .hour {
                orderDetailInfoModel?.orderType = 1
                orderDetailInfoModel?.svcHoursPrices = model as? HoursAndTimesPricesModel
            } else {
                orderDetailInfoModel?.orderType = 2
                orderDetailInfoModel?.svcTimesPrices = model as? HoursAndTimesPricesModel
            }
            orderDetailInfoModel?.depositStatusName = LocalizedString("Lang_RD_025")
            orderDetailInfoModel?.finalPaymentStatusName = LocalizedString("Lang_RD_027")
        }
        let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: ReserveStoreDateViewController.self)) as! ReserveStoreDateViewController
        vc.setupVCWith(orderDetailInfoModel: orderDetailInfoModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension NoOrderPricingPlanViewController: RentSchemeViewControllerDelegate {
    func confirmButtonPressWith(selectModel: Codable, purchase: Bool) {
        orderDetailInfoModel?.svcHoursPrices = nil
        orderDetailInfoModel?.svcTimesPrices = nil
        if selectModel is LongLeasePricesModel {
            orderDetailInfoModel?.svcLongLeasePrices = selectModel as? LongLeasePricesModel
        }
        
        // 選擇已購買方案，跳轉至預約日期
        // 選擇未購買方案，直接跳轉至預約詳情
        if purchase {
            orderDetailInfoModel?.orderType = 4
            orderDetailInfoModel?.finalPaymentStatusName = LocalizedString("Lang_PS_011")
            let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: ReserveStoreDateViewController.self)) as! ReserveStoreDateViewController
            vc.setupVCWith(orderDetailInfoModel: orderDetailInfoModel)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            orderDetailInfoModel?.orderType = 3
            orderDetailInfoModel?.finalPaymentStatusName = LocalizedString("Lang_RD_025")
            let finalPayment = orderDetailInfoModel?.svcLongLeasePrices?.prices ?? 0
            orderDetailInfoModel?.finalPayment = finalPayment
            let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: OperatingReservationDetailViewController.self)) as! OperatingReservationDetailViewController
            vc.setupVCWith(doId: nil, orderDetailInfoModel: orderDetailInfoModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

