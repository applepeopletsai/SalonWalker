//
//  HasOrderPricingPlanViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/11.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

// 有消費者預約設計師(設計師依客戶預約訂單預約場地)
class HasOrderPricingPlanViewController: BaseViewController {
    
    @IBOutlet private weak var naviTitleLabel: UILabel!
    @IBOutlet private weak var hoursViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var timesViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var longLeaseViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var hoursOrderTimeLabel: UILabel!
    @IBOutlet private weak var hoursPriceLabel: UILabel!
    @IBOutlet private weak var timesOrderTimeLabel: UILabel!
    @IBOutlet private weak var timesPriceLabel: UILabel!
    @IBOutlet private weak var longLeaseOrderTimeLabel: UILabel!
    @IBOutlet private weak var longLeasePriceLabel: UILabel!
    
    
    private var moId: Int?
    private var orderSvcPriceModel: OrderSvcPricesModel?
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
    func setupVCWith(moId: Int, orderDetailInfoModel: OrderDetailInfoModel?) {
        self.moId = moId
        self.orderDetailInfoModel = orderDetailInfoModel
    }
    
    private func callAPI() {
        if orderSvcPriceModel == nil {
            apiGetOrderSvcPrices()
        }
    }
    
    private func initialize() {
        self.naviTitleLabel.text = orderDetailInfoModel?.provider?.nickName
    }
    
    private func setupUI() {
        if let model = orderSvcPriceModel {
            if let hours = model.svcHoursPrices {
                hoursOrderTimeLabel.text = hours.weekDay.transferToWeekString()
                hoursPriceLabel.text = "$\(hours.prices.transferToDecimalString())"
                hoursViewHeight.constant = 100
            } else {
                hoursViewHeight.constant = 0
            }
            if let times = model.svcTimesPrices {
                timesOrderTimeLabel.text = times.weekDay.transferToWeekString()
                timesPriceLabel.text = "$\(times.prices.transferToDecimalString())"
                timesViewHeight.constant = 100
            } else {
                timesViewHeight.constant = 0
            }
            if let longLease = model.svcLongLeasePrices {
                if let startDay = longLease.startDay, let endDay = longLease.endDay, let price = longLease.prices {
                    longLeaseOrderTimeLabel.text = "\(startDay.replacingOccurrences(of: "-", with: "/")) \(LocalizedString("Lang_DD_012")) \(endDay.replacingOccurrences(of: "-", with: "/"))"
                    longLeasePriceLabel.text = "$\(price)"
                    longLeaseViewHeight.constant = 100
                } else {
                    longLeaseViewHeight.constant = 0
                }
            } else {
                longLeaseViewHeight.constant = 0
            }
        }
    }
    
    // MARK: Event Handler
    /*
     orderType(訂單類別)：
     1:小時方案
     2:次數方案
     3:長租方案 (購買)
     4:長租方案 (使用)
     */
    @IBAction func hourButtonClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: ReserveStoreDateViewController.self)) as! ReserveStoreDateViewController
        orderDetailInfoModel?.svcHoursPrices = HoursAndTimesPricesModel(weekDay: orderSvcPriceModel!.svcHoursPrices!.weekDay, prices: orderSvcPriceModel!.svcHoursPrices!.prices)
        orderDetailInfoModel?.orderType = 1
        orderDetailInfoModel?.depositStatusName = LocalizedString("Lang_RD_025")
        orderDetailInfoModel?.finalPaymentStatusName = LocalizedString("Lang_RD_027")
        vc.setupVCWith(orderDetailInfoModel: orderDetailInfoModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func timesButtonClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: ReserveStoreDateViewController.self)) as! ReserveStoreDateViewController
        orderDetailInfoModel?.svcTimesPrices = HoursAndTimesPricesModel(weekDay: orderSvcPriceModel!.svcTimesPrices!.weekDay, prices: orderSvcPriceModel!.svcTimesPrices!.prices)
        orderDetailInfoModel?.orderType = 2
        orderDetailInfoModel?.depositStatusName = LocalizedString("Lang_RD_025")
        orderDetailInfoModel?.finalPaymentStatusName = LocalizedString("Lang_RD_027")
        vc.setupVCWith(orderDetailInfoModel: orderDetailInfoModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func longRentButtonClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: ReserveStoreDateViewController.self)) as! ReserveStoreDateViewController
        orderDetailInfoModel?.svcLongLeasePrices = LongLeasePricesModel(startDay: orderSvcPriceModel?.svcLongLeasePrices?.startDay, endDay: orderSvcPriceModel?.svcLongLeasePrices?.endDay, prices: orderSvcPriceModel?.svcLongLeasePrices?.prices)
        // 這裡只會出現設計師有預約長租的場地
        orderDetailInfoModel?.orderType = 4
        orderDetailInfoModel?.finalPaymentStatusName = LocalizedString("Lang_PS_011")
        vc.setupVCWith(orderDetailInfoModel: orderDetailInfoModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: API
    private func apiGetOrderSvcPrices() {
        guard let moId = moId else { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            ReservationManager.apiGetOrderSvcPrices(moId: moId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.orderSvcPriceModel = model?.data
                    self.setupUI()
                    self.removeMaskView()
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
}


