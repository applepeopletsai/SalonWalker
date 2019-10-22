//
//  ConfirmRentPriceViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ConfirmRentPriceViewController: BaseViewController {

    @IBOutlet private weak var naviTitleLabel: UILabel!
    @IBOutlet private weak var orderDateLabel: UILabel!
    @IBOutlet private weak var orderTimeLabel: UILabel!
    @IBOutlet private weak var orderTypeLabel: UILabel!
    @IBOutlet private weak var unitLabel: UILabel!
    @IBOutlet private weak var unitPriceLabel: UILabel!
    @IBOutlet private weak var totalPriceLabel: UILabel!
    
    private var model: OrderDetailInfoModel?
    private var startTime = ""
    private var endTime = ""
    private var totalPrice = 0
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: Method
    func setupVCWith(model: OrderDetailInfoModel) {
        self.model = model
    }
    
    private func configureUI() {
        naviTitleLabel.text = model?.designer?.nickName
        
        if let model = model {
            configureOrderTime(model: model)
            configureOrderTypeAndPrice(model: model)
        }
    }
    
    private func configureOrderTime(model: OrderDetailInfoModel) {
        if let endTime = model.endTime {
            let orderTime = model.orderTime.transferToDate(dateFormat: "yyyy-MM-dd HH:mm:ss")
            let estimateEndTime = endTime.transferToDate(dateFormat: "yyyy-MM-dd HH:mm:ss")
            let week = orderTime.getDayOfWeek().transferToWeekString()
            orderDateLabel.text = orderTime.transferToString(dateFormat: "yyyy/MM/dd") + " \(week)"
            orderTimeLabel.text = "\(orderTime.transferToString(dateFormat: "HH:mm")) - \(estimateEndTime.transferToString(dateFormat: "HH:mm"))"
            self.startTime = orderTime.transferToString(dateFormat: "HH:mm")
            self.endTime = estimateEndTime.transferToString(dateFormat: "HH:mm")
        }
    }
    
    private func configureOrderTypeAndPrice(model: OrderDetailInfoModel) {
        totalPrice = model.deposit + model.finalPayment
        totalPriceLabel.text = "$\(totalPrice.transferToDecimalString())"
        
        if let orderType = model.orderType {
            switch orderType {
            case 1:
                orderTypeLabel.text = LocalizedString("Lang_PS_002")
                unitLabel.text = LocalizedString("Lang_PS_009")
                unitPriceLabel.text = "$\(model.svcHoursPrices?.prices.transferToDecimalString() ?? "0")"
                break
            case 2:
                orderTypeLabel.text = LocalizedString("Lang_PS_003")
                unitLabel.text = LocalizedString("Lang_PS_010")
                unitPriceLabel.text = "$\(model.svcTimesPrices?.prices.transferToDecimalString() ?? "0")"
                break
            case 3,4:
                orderTypeLabel.text = LocalizedString("Lang_PS_004")
                unitLabel.text = nil
                unitPriceLabel.text = "$\(model.svcLongLeasePrices?.prices?.transferToDecimalString() ?? "0")"
                break
            default:
                orderTypeLabel.text = nil
                break
            }
        } else {
            orderTypeLabel.text = nil
        }
    }
    
    private func getEndTimeArray() -> [String] {
        let firstTime = startTime.transferToDate(dateFormat: "HH:mm").addingTimeInterval(30 * 60)
        let lastTime = "23:30".transferToDate(dateFormat: "HH:mm")
        
        var array = [firstTime]
        
        while array.last! < lastTime {
            array.append(array.last!.addingTimeInterval(30 * 60))
        }
        return array.map{ $0.transferToString(dateFormat: "HH:mm") }
    }
    
    // MARK: Event Handler
    @IBAction private func orderTimeButtonPress(_ sender: UIButton) {
        let itemArray = getEndTimeArray()
        let index = itemArray.index(of: self.endTime) ?? 0
        PresentationTool.showPickerWith(itemArray: itemArray, selectedIndex: index, hintTitle: LocalizedString("Lang_RV_028"), cancelAction: nil, confirmAction: { [unowned self] (text, index) in
            self.endTime = text
            
            // 小時要計算總價
            if self.model?.orderType == 1 {
                self.orderTimeLabel.text = "\(self.startTime) - \(text)"
                let hours = self.endTime.transferToDate(dateFormat: "HH:mm").timeIntervalSince(self.startTime.transferToDate(dateFormat: "HH:mm")) / 60 / 60
                self.totalPrice = Int(Double(self.model?.svcHoursPrices?.prices ?? 0) * hours)
                self.totalPriceLabel.text = "$\(self.totalPrice.transferToDecimalString())"
            }
        })
    }
    
    @IBAction private func confirmButtonPress(_ sender: UIButton) {
        apiSetDesignerOrderSvcItems()
    }
    
    // MARK: API
    private func apiSetDesignerOrderSvcItems() {
        guard let doId = model?.doId, let orderType = model?.orderType else { return  }
        if SystemManager.isNetworkReachable() {
            
            self.showLoading()
            
            ReservationManager.apiSetDesignerOrderSvcItems(doId: doId, orderType: orderType, endTime: endTime, total: totalPrice, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    
                    PresentationTool.showOneButtonAlertWith(image: UIImage(named: "img_pop_barbershop"), message: model?.data?.msg ?? LocalizedString("Lang_SD_028"), buttonTitle: LocalizedString("Lang_GE_027"), buttonAction: { [unowned self] in
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                } else {
                    self.endLoadingWith(model: model)
                }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
            
        }
    }
    
}


