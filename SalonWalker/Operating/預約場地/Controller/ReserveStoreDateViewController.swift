//
//  ReserveStoreDateViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/18.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ReserveStoreDateViewController: BaseViewController {
    
    @IBOutlet private weak var naviTitleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var startTimeLabel: UILabel!
    @IBOutlet private weak var endTimeLabel: UILabel!
    @IBOutlet private weak var dateButton: UIButton!
    @IBOutlet private weak var startTimeButton: UIButton!
    @IBOutlet private weak var dateImageView: UIImageView!
    @IBOutlet private weak var startTimeArrowImageView: UIImageView!
    @IBOutlet private weak var reservationButton: UIButton!
    
    private var orderDetailInfoModel: OrderDetailInfoModel?
    private var dateArray = [Date]()
    private var startTimeArray = [Date]()
    private var endTimeArray = [Date]()
    
    private var orderDate: String?
    private var startTime: String?
    private var endTime: String?
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
            self?.callAPI()
        })
    }
    
    // MARK: Method
    func setupVCWith(orderDetailInfoModel: OrderDetailInfoModel?) {
        self.orderDetailInfoModel = orderDetailInfoModel
    }
    
    private func callAPI() {
        // 如果是消費者訂單，直接顯示消費者的預約日期及開始時間
        // 如果是直接預約場地，需要call API取得可以預約的日期
        if orderDetailInfoModel?.member == nil {
            apiGetSvcTime()
        }
    }
    
    private func initialize() {
        naviTitleLabel.text = orderDetailInfoModel?.provider?.nickName
        if let model = orderDetailInfoModel {
            if model.orderTime.count > 0 {
                orderDate = model.orderTime.subString(from: 0, to: 9).replacingOccurrences(of: "-", with: "/")
                startTime = model.orderTime.subString(from: 11, to: 15)
                
                dateLabel.text = orderDate
                startTimeLabel.text = startTime
                dateLabel.textColor = .black
                startTimeLabel.textColor = .black
                dateButton.isEnabled = false
                startTimeButton.isEnabled = false
                dateImageView.isHidden = true
                startTimeArrowImageView.isHidden = true
                setupEndTimeArray()
            } else {
                dateLabel.text = LocalizedString("Lang_GE_007")
                startTimeLabel.text = LocalizedString("Lang_GE_007")
                dateLabel.textColor = color_9B9B9B
                startTimeLabel.textColor = color_9B9B9B
                dateButton.isEnabled = true
                startTimeButton.isEnabled = true
                dateImageView.isHidden = false
                startTimeArrowImageView.isHidden = false
                setupStartTimeArray()
            }
            endTimeLabel.text = LocalizedString("Lang_GE_007")
            endTimeLabel.textColor = color_9B9B9B
        }
    }
    
    private func setupStartTimeArray() {
        startTimeArray.removeAll()
        
        let firstTime = "08:00".transferToDate(dateFormat: "HH:mm")
        let lastTime = "23:00".transferToDate(dateFormat: "HH:mm")
        startTimeArray.append(firstTime)
        while startTimeArray.last! < lastTime {
            startTimeArray.append(startTimeArray.last!.addingTimeInterval(30 * 60))
        }
    }
    
    private func setupEndTimeArray() {
        endTimeArray.removeAll()
        
        if let date = orderDate, let startTime = startTime {
            let endTime = (orderDetailInfoModel?.estimateEndTime == nil) ? "\(date.subString(from: 0, to: 9)) 23:30" : orderDetailInfoModel!.estimateEndTime!.subString(from: 0, to: 15).replacingOccurrences(of: "-", with: "/")
            let firstTime = "\(date) \(startTime)".transferToDate(dateFormat: "yyyy/MM/dd HH:mm").addingTimeInterval(30 * 60)
            let lastTime = endTime.transferToDate(dateFormat: "yyyy/MM/dd HH:mm")
            endTimeArray.append(firstTime)
            while endTimeArray.last! < lastTime {
                endTimeArray.append(endTimeArray.last!.addingTimeInterval(30 * 60))
            }
        }
    }
    
    private func gotoOrderDetailVC() {
        let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: OperatingReservationDetailViewController.self)) as! OperatingReservationDetailViewController
        orderDetailInfoModel?.orderStatus = 0
        
        /*
         orderType(訂單類別)：
         1:小時方案
         2:次數方案
         3:長租方案 (購買)
         4:長租方案 (使用)
         */
        // 計算服務總價
        switch orderDetailInfoModel?.orderType {
        case 1,2:
            var totalPrice = 0
            if orderDetailInfoModel?.orderType == 1 {
                orderDetailInfoModel?.svcTimesPrices = nil
                if let prices = orderDetailInfoModel?.svcHoursPrices?.prices {
                    let hour = endTime!.transferToDate(dateFormat: "HH:mm").timeIntervalSince(startTime!.transferToDate(dateFormat: "HH:mm")) / 60 / 60
                    totalPrice = Int(Double(prices) * hour)
                }
            } else {
                orderDetailInfoModel?.svcHoursPrices = nil
                if let prices = orderDetailInfoModel?.svcTimesPrices?.prices {
                    totalPrice = prices
                }
            }
            if totalPrice != 0 {
                let deposit = (totalPrice > 300) ? 300 : totalPrice / 2
                let finalPayment = totalPrice - deposit
                orderDetailInfoModel?.deposit = deposit
                orderDetailInfoModel?.finalPayment = finalPayment
            } else {
                orderDetailInfoModel?.deposit = 0
                orderDetailInfoModel?.finalPayment = 0
            }
            break
        case 3:
            if let prices = orderDetailInfoModel?.svcLongLeasePrices?.prices {
                orderDetailInfoModel?.finalPayment = prices
            }
            break
        case 4:
            orderDetailInfoModel?.finalPayment = 0
            break
        default: break
        }
        vc.setupVCWith(doId: nil, orderDetailInfoModel: orderDetailInfoModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func checkReservationButtonEnable() {
        if orderDate != nil, startTime != nil, endTime != nil {
            self.reservationButton.isEnabled = true
            self.reservationButton.backgroundColor = color_1A1C69
        } else {
            self.reservationButton.isEnabled = false
            self.reservationButton.backgroundColor = color_9B9B9B
        }
    }
    
    // MARK: Event Handler
    @IBAction private func calendarButtonClick(_ sender: UIButton) {
        PresentationTool.showCalendarWith(canSelectDayArray: dateArray, cancelAction: nil) { [unowned self] (date) in
            self.orderDate = date.transferToString(dateFormat: "yyyy/MM/dd")
            self.dateLabel.text = self.orderDate
            self.dateLabel.textColor = .black
            self.startTimeLabel.text = LocalizedString("Lang_GE_007")
            self.startTimeLabel.textColor = color_9B9B9B
            self.endTimeLabel.text = LocalizedString("Lang_GE_007")
            self.endTimeLabel.textColor = color_9B9B9B
            self.startTime = nil
            self.endTime = nil
            self.orderDetailInfoModel?.orderTime = self.orderDate!.replacingOccurrences(of: "/", with: "-")
            self.orderDetailInfoModel?.endTime = nil
            self.checkReservationButtonEnable()
        }
    }
    
    @IBAction private func startTimeButtonClick(_ sender: UIButton) {
        if orderDate == nil {
            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_RV_011"), body: "")
            return
        }
        let array = startTimeArray.map{ $0.transferToString(dateFormat: "HH:mm") }
        let index = array.index(of: startTime ?? "") ?? 0
        PresentationTool.showPickerWith(itemArray: array, selectedIndex: index, cancelAction: nil) { [unowned self] (text, index) in
            self.startTimeLabel.text = text
            self.startTimeLabel.textColor = .black
            self.startTime = text
            self.endTimeLabel.text = LocalizedString("Lang_GE_007")
            self.endTimeLabel.textColor = color_9B9B9B
            self.endTime = nil
            self.orderDetailInfoModel?.orderTime = "\(self.orderDate!.replacingOccurrences(of: "/", with: "-")) \(text):00"
            self.orderDetailInfoModel?.endTime = nil
            self.setupEndTimeArray()
            self.checkReservationButtonEnable()
        }
    }
   
    @IBAction private func endTimeButtonClick(_ sender: IBInspectableButton) {
        if startTime == nil {
            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_RV_013"), body: "")
            return
        }
        let array = endTimeArray.map{ $0.transferToString(dateFormat: "HH:mm") }
        let index = array.index(of: endTime ?? "") ?? 0
        PresentationTool.showPickerWith(itemArray: array, selectedIndex: index, cancelAction: nil) { [unowned self] (text, index) in
            self.endTimeLabel.text = text
            self.endTimeLabel.textColor = .black
            self.endTime = text
            self.orderDetailInfoModel?.endTime = "\(self.orderDate!.replacingOccurrences(of: "/", with: "-")) \(text):00"
            self.checkReservationButtonEnable()
        }
    }
    
    @IBAction private func bookButtonClick(_ sender: UIButton) {
        // 如果是消費者訂單，則不需檢查是否可預約
        // 如果是直接預約場地，則需檢查是否可預約
        if orderDetailInfoModel?.member != nil {
            gotoOrderDetailVC()
        } else {
            apiGetSvcTime()
        }
    }
    
    // MARK: API
    private func apiGetSvcTime() {
        guard let pId = orderDetailInfoModel?.provider?.pId else { return }
        
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            ReservationManager.apiGetSvcTime(pId: pId, svcDate: orderDate, startTime: startTime, endTime: endTime, model: orderDetailInfoModel, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    
                    if model?.data?.svcDate == nil && model?.data?.recSeat == nil {
                        SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_PS_013"), alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_056"), handler: {
                            self.navigationController?.popViewController(animated: true)
                        })
                        return
                    }
                    
                    if let svcDate = model?.data?.svcDate {
                        self.dateArray = svcDate.map{ $0.transferToDate(dateFormat: "yyyy/MM/dd") }
                    }
                    
                    if let recSeat = model?.data?.recSeat {
                        if !recSeat.isRecSeat {
                            SystemManager.showAlertWith(alertTitle: recSeat.recSeatMsg, alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
                        } else {
                            self.gotoOrderDetailVC()
                        }
                    }
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
}


