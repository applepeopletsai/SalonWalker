//
//  ReserveDesignerDateViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/7.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ReserveDesignerDateViewController: BaseViewController {

    @IBOutlet private weak var naviTitleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var storeLocationLabel: UILabel!
    
    private var dateArray = [String]()
    private var timeArray = [String]()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    // MARK: Method
    override func networkDidRecover() {
        callAPI()
    }
    
    private func callAPI() {
        if dateArray.count == 0 {
            apiGetRecSvcDate(success: { [weak self] in
                if ReservationManager.shared.reservationDetailModel?.orderDate != nil {
                    self?.dateLabel.text = ReservationManager.shared.reservationDetailModel?.orderDate
                    self?.dateLabel.textColor = .black
                    self?.apiGetRecSvcDate(date: ReservationManager.shared.reservationDetailModel?.orderDate)
                }
            })
        }
    }
    
    private func showCalendar() {
        let dayArray = dateArray.map{ $0.transferToDate(dateFormat: "yyyy/MM/dd") }
        PresentationTool.showCalendarWith(canSelectDayArray: dayArray, cancelAction: nil) { [unowned self] (date) in
            let dateString = date.transferToString(dateFormat: "yyyy/MM/dd")
            self.dateLabel.text = dateString
            self.dateLabel.textColor = .black
            ReservationManager.shared.reservationDetailModel?.orderDate = dateString
            ReservationManager.shared.reservationDetailModel?.week = date.getDayOfWeek().transferToWeekString()
            self.timeLabel.text = "00:00"
            self.timeLabel.textColor = color_9B9B9B
            ReservationManager.shared.reservationDetailModel?.orderTime = nil
            self.storeLocationLabel.text = LocalizedString("Lang_RV_003")
            self.storeLocationLabel.textColor = color_9B9B9B
            ReservationManager.shared.reservationDetailModel?.pId = nil
            self.apiGetRecSvcDate(date: dateString)
        }
    }
    
    private func showTimePicker() {
        let index = timeArray.index(of: ReservationManager.shared.reservationDetailModel?.orderTime ?? "") ?? 0
        PresentationTool.showPickerWith(itemArray: timeArray, selectedIndex: index, cancelAction: nil) { [unowned self] (text, index) in
            self.timeLabel.text = text
            self.timeLabel.textColor = .black
            ReservationManager.shared.reservationDetailModel?.orderTime = text
            self.storeLocationLabel.text = LocalizedString("Lang_RV_003")
            self.storeLocationLabel.textColor = color_9B9B9B
            ReservationManager.shared.reservationDetailModel?.pId = nil
        }
    }
    
    private func checkAlreadySelectDate() -> Bool {
        if ReservationManager.shared.reservationDetailModel?.orderDate == nil {
            SystemManager.showWarningBanner(title: LocalizedString("Lang_RV_011"), body: "")
            return false
        }
        return true
    }
    
    private func checkAlreadySelectTime() -> Bool {
        if ReservationManager.shared.reservationDetailModel?.orderTime == nil {
            SystemManager.showWarningBanner(title: LocalizedString("Lang_RV_012"), body: "")
            return false
        }
        return true
    }
    
    private func checkAlreadySelectSvcPosition() -> Bool {
        if ReservationManager.shared.reservationDetailModel?.pId == nil {
            SystemManager.showWarningBanner(title: LocalizedString("Lang_RV_014"), body: "")
            return false
        }
        return true
    }
    
    // MARK: Event Handler
    @IBAction private func dateButtonPress(_ sender: UIButton) {
        if dateArray.count > 0 {
            showCalendar()
        } else {
            apiGetRecSvcDate(success: { [unowned self] in
                self.showCalendar()
            })
        }
    }
    
    @IBAction private func timeButtonPress(_ sender: UIButton) {
        if !checkAlreadySelectDate() { return }
        
        if timeArray.count > 0 {
            showTimePicker()
        } else {
            apiGetRecSvcDate(date: ReservationManager.shared.reservationDetailModel?.orderDate, success: { [weak self] in
                self?.showTimePicker()
            })
        }
    }
    
    @IBAction private func locationButtonPress(_ sender: UIButton) {
        if !checkAlreadySelectDate() { return }
        if !checkAlreadySelectTime() { return }
        
        guard let dId = ReservationManager.shared.reservationDetailModel?.dId, let orderDate = ReservationManager.shared.reservationDetailModel?.orderDate, let statrTime = ReservationManager.shared.reservationDetailModel?.orderTime, let designerSvcItemsModel = ReservationManager.shared.reservationDetailModel?.svcContent else { return }
        let vc = UIStoryboard(name: kStory_ReserveDesigner, bundle: nil).instantiateViewController(withIdentifier: String(describing: SelectServiceLocationViewController.self)) as! SelectServiceLocationViewController
        vc.setupVCWith(dId: dId, orderDate: orderDate, startTime: statrTime, svcTimeTotal: ReservationManager.calculateServiceTotalValue(selectCategory: designerSvcItemsModel.svcCategory ?? [], type: .Time), delegate: self)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func nextStepButtonPress(_ sender: UIButton) {
        if !checkAlreadySelectDate() { return }
        if !checkAlreadySelectTime() { return }
        if !checkAlreadySelectSvcPosition() { return }
        let vc = UIStoryboard(name: kStory_ReserveDesigner, bundle: nil).instantiateViewController(withIdentifier: String(describing: ReserveDesignerHairStyleViewController.self)) as! ReserveDesignerHairStyleViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func cancelReservationButtonPress(_ sender: UIButton) {
        guard let naviVCs = self.navigationController?.viewControllers else { return }
        for vc in naviVCs {
            if vc is DesignerDetailViewController {
                self.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: API
    private func apiGetRecSvcDate(date: String? = nil, success: actionClosure? = nil) {
        guard let dId = ReservationManager.shared.reservationDetailModel?.dId, let model = ReservationManager.shared.reservationDetailModel?.svcContent else { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            ReservationManager.apiGetRecSvcDate(dId: dId, svcTimeTotal: ReservationManager.calculateServiceTotalValue(selectCategory: model.svcCategory ?? [], type: .Time), svcDate: date, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    
                    if let svcDate = model?.data?.svcDate {
                        self.dateArray = svcDate
                    }
                    
                    if let svcTime = model?.data?.svcTime {
                        self.timeArray = svcTime
                    }
                    
                    self.hideLoading()
                    success?()
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension ReserveDesignerDateViewController: SelectServiceLocationViewControllerDelegate {
    
    func didSelectStoreWith(model: SvcPlaceModel) {
        ReservationManager.shared.reservationDetailModel?.pId = model.pId
        ReservationManager.shared.reservationDetailModel?.placeName = model.nickName
        self.storeLocationLabel.text = model.nickName
        self.storeLocationLabel.textColor = .black
    }
}
