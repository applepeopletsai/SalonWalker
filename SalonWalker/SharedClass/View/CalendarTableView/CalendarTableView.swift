//
//  CalendarTableView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol CalendarTableViewDelegate: class {
    func didUpdateDataWith(startDate: Date, endDate: Date, hasOrderDateArray: [Date])
}

class CalendarTableView: UITableView {

    private var dataArray = [Codable]()
    private var displayArray = [Codable]()
    
    private weak var targetVC: BaseViewController?
    private weak var calendarTableViewDelegate: CalendarTableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = self
        self.delegate = self
        registerCell()
    }
    
    func setupTableViewWith(targetViewcontroller: BaseViewController, delegate: CalendarTableViewDelegate?) {
        self.targetVC = targetViewcontroller
        self.calendarTableViewDelegate = delegate
    }

    func resetDataWith(startDate: Date, endDate: Date) {
        if UserManager.sharedInstance.userIdentity == .consumer {
            apiGetMemberCalendar(startDate: startDate, endDate: endDate)
        } else {
            apiGetDesignerCalendar(startDate: startDate, endDate: endDate)
        }
    }

    func clearDisplayData() {
        self.displayArray = []
        self.reloadData()
    }
    
    func reloadDataWithSelectDate(_ date: Date) {
        let selectDateStirng = date.transferToString(dateFormat: "yyyy-MM-dd")
        for model in dataArray {
            if model is MemberCalendarModel.Calendar {
                let m = (model as! MemberCalendarModel.Calendar)
                if m.date == selectDateStirng {
                    displayArray = m.order
                    self.reloadData()
                    return
                }
            } else if model is OperatingCalendarModel.Calendar {
                let m = (model as! OperatingCalendarModel.Calendar)
                if m.date == selectDateStirng {
                    displayArray = m.order
                    self.reloadData()
                    return
                }
            }
        }
        clearDisplayData()
    }
    
    private func getOrderDateArray() -> [Date] {
        var hasOrderDateArray = [Date]()
        for model in self.dataArray {
            if model is MemberCalendarModel.Calendar {
                hasOrderDateArray.append((model as! MemberCalendarModel.Calendar).date.transferToDate(dateFormat: "yyyy-MM-dd"))
            } else if model is OperatingCalendarModel.Calendar {
                hasOrderDateArray.append((model as! OperatingCalendarModel.Calendar).date.transferToDate(dateFormat: "yyyy-MM-dd"))
            }
        }
        return hasOrderDateArray
    }
    
    private func registerCell() {
        self.register(UINib(nibName: String(describing: CalendarTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: CalendarTableViewCell.self))
    }
    
    // MARK: API
    private func apiGetMemberCalendar(startDate: Date, endDate: Date) {
        if SystemManager.isNetworkReachable() {
            self.targetVC?.showLoading()
            
            let start = startDate.transferToString(dateFormat: "yyyy-MM-dd")
            let end = endDate.transferToString(dateFormat: "yyyy-MM-dd")
            OrderDataManager.apiGetMemberCalandar(startDate: start, endDate: end, success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    if let calendar = model?.data?.calendar {
                        self.dataArray = calendar
                    }
                    self.targetVC?.hideLoading()
                    self.calendarTableViewDelegate?.didUpdateDataWith(startDate: startDate, endDate: endDate, hasOrderDateArray: self.getOrderDateArray())
                } else {
                    self.targetVC?.endLoadingWith(model: model)
                }
                
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiGetDesignerCalendar(startDate: Date, endDate: Date) {
        if SystemManager.isNetworkReachable() {
            self.targetVC?.showLoading()
            
            let start = startDate.transferToString(dateFormat: "yyyy-MM-dd")
            let end = endDate.transferToString(dateFormat: "yyyy-MM-dd")
            OrderDataManager.apiGetOperatingCalendar(startDate: start, endDate: end, success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    if let calendar = model?.data?.calendar {
                        self.dataArray = calendar
                    }
                    self.targetVC?.hideLoading()
                    self.calendarTableViewDelegate?.didUpdateDataWith(startDate: startDate, endDate: endDate, hasOrderDateArray: self.getOrderDateArray())
                } else {
                    self.targetVC?.endLoadingWith(model: model)
                }
                
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension CalendarTableView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CalendarTableViewCell.self), for: indexPath) as! CalendarTableViewCell
        let topLineHidden = (indexPath.row == 0)
        let bottomLineHidden = (indexPath.row == displayArray.count - 1)
        if displayArray[indexPath.row] is MemberOrderModel {
            cell.setupCellWith(memberModel: displayArray[indexPath.row] as! MemberOrderModel, topLineHidden: topLineHidden, bottomLineHidden: bottomLineHidden)
        }
        if displayArray[indexPath.row] is CalendarModel_Operating {
            cell.setupCellWith(operatingModel: displayArray[indexPath.row] as! CalendarModel_Operating, topLineHidden: topLineHidden, bottomLineHidden: bottomLineHidden)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        #if SALONWALKER
        if displayArray[indexPath.row] is MemberOrderModel {
            let vc = UIStoryboard(name: kStory_ReserveDesigner, bundle: nil).instantiateViewController(withIdentifier: String(describing: ConsumerReservationDetailViewController.self)) as! ConsumerReservationDetailViewController
            vc.setupVCWith(moId: (displayArray[indexPath.row] as! MemberOrderModel).moId)
            self.targetVC?.navigationController?.pushViewController(vc, animated: true)
        }
        #endif
        #if SALONMAKER
        if displayArray[indexPath.row] is CalendarModel_Operating {
            if let memberOrder = (displayArray[indexPath.row] as! CalendarModel_Operating).memberOrder {
                let vc = UIStoryboard(name: "OrderRecord", bundle: nil).instantiateViewController(withIdentifier: String(describing: DesignerReservationByConsumerDetailViewController.self)) as! DesignerReservationByConsumerDetailViewController
                vc.setupVCWith(moId: memberOrder.moId)
                self.targetVC?.navigationController?.pushViewController(vc, animated: true)
            } else if let designerOrder = (displayArray[indexPath.row] as! CalendarModel_Operating).designerOrder {
                let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: OperatingReservationDetailViewController.self)) as! OperatingReservationDetailViewController
                vc.setupVCWith(doId: designerOrder.doId, orderDetailInfoModel: nil)
                self.targetVC?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        #endif
    }
}
