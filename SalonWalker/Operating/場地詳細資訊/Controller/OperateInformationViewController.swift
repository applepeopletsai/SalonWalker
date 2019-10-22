//
//  OperateInformationViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/3/28.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class OperateInformationViewController: MultipleScrollBaseViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var serviceTimeArrayForChart: [[OpenHourModel]] = []
    
    var providerDetailModel: ProviderDetailModel? {
        didSet {
            if oldValue == nil {
                setupUI()
            }
        }
    }
    
    private var chartCellHeight: CGFloat {
        if SizeTool.isIphoneX() {
            return screenHeight * 0.4
        } else {
            return screenHeight * 0.45
        }
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.alwaysBounceVertical = true
    }
    
    // MARK: Method
    private func setupUI() {
        serviceTimeArrayForChart.removeAll()
        if let openHour = providerDetailModel?.openHour {
            serviceTimeArrayForChart = DetailManager.transferToWorkTimeArrayForChart(openHour)
            // 星期天從第一個移到最後一個
            serviceTimeArrayForChart.append(serviceTimeArrayForChart.removeFirst())
        }
        tableView.reloadData()
    }
}

extension OperateInformationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = providerDetailModel?.openHour?.count {
            // 消費者不顯示計價方案
            return (UserManager.sharedInstance.userIdentity == .consumer) ? count + 1 : count + 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if UserManager.sharedInstance.userIdentity != .consumer {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PriceSchemeCell", for: indexPath)
                return cell
            } else if indexPath.row < (providerDetailModel?.openHour?.count ?? 0) + 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ServiceTimeCell.self), for: indexPath) as! ServiceTimeCell
                if let openHour = providerDetailModel?.openHour?[indexPath.row - 1] {
                    cell.setupCellWith(week: openHour.weekDay, fromTime: openHour.from, toTime: openHour.end)
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ServiceTimeChartCell.self), for: indexPath) as! ServiceTimeChartCell
                cell.setupCellWith(cellHeight: chartCellHeight, serviceTimeArray: serviceTimeArrayForChart)
                return cell
            }
        } else {
            if indexPath.row < (providerDetailModel?.openHour?.count ?? 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ServiceTimeCell.self), for: indexPath) as! ServiceTimeCell
                if let openHour = providerDetailModel?.openHour?[indexPath.row] {
                    cell.setupCellWith(week: openHour.weekDay, fromTime: openHour.from, toTime: openHour.end)
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ServiceTimeChartCell.self), for: indexPath) as! ServiceTimeChartCell
                cell.setupCellWith(cellHeight: chartCellHeight, serviceTimeArray: serviceTimeArrayForChart)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UserManager.sharedInstance.userIdentity != .consumer {
            if indexPath.row == 0 {
                return 60.0
            } else if indexPath.row < (providerDetailModel?.openHour?.count ?? 0) + 1 {
                return screenHeight * 0.1
            } else {
                return chartCellHeight
            }
        } else {
            if indexPath.row < (providerDetailModel?.openHour?.count ?? 0) {
                return screenHeight * 0.1
            } else {
                return chartCellHeight
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        #if SALONMAKER
        if indexPath.row == 0 {
            if let providerDetailModel = providerDetailModel {
                let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: NoOrderPricingPlanViewController.self)) as! NoOrderPricingPlanViewController
                let provider = OrderDetailInfo_Provider(pId: providerDetailModel.pId, nickName: providerDetailModel.nickName, headerImgUrl: providerDetailModel.headerImgUrl, cityName: providerDetailModel.cityName, areaName: providerDetailModel.areaName, address: providerDetailModel.address, telArea: providerDetailModel.telArea, tel: providerDetailModel.tel, orderStatusName: "")
                let evaluate = EvaluateStatusModel(statusName: "", evaluation: nil)
                let model = OrderDetailInfoModel(moId: nil, doId: nil, bindMoId: nil, bindDoId: nil, orderNo: "", orderType: nil, orderTime: "", estimateEndTime: nil, endTime: nil, deposit: 0, depositStatusName: "", finalPayment: 0, finalPaymentStatusName: "", paymentTypeName: "", orderStatus: 0, member: nil, designer: nil, provider: provider, svcContent: nil, evaluateStatus: evaluate, svcHoursPrices: nil, svcTimesPrices: nil, svcLongLeasePrices: nil)
                vc.setupVCWith(model: model, type: .check)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        #endif
    }
}
