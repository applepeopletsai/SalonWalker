//
//  ConfirmServiceContentViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/11.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ConfirmServiceContentViewController: BaseViewController {

    @IBOutlet private weak var tableView: ServiceItemsTableView!
    @IBOutlet private weak var naviTitleLabel: UILabel!
    
    private var mId: Int?
    private var dId: Int?
    private var moId: Int?
    private var customerName: String?
    private var orderSvcItemModel: OrderSvcItemsModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.callAPI()
    }
    
    // MARK: Method
    override func networkDidRecover() {
        tableView.callAPI()
    }
    
    func setupVCWith(mId: Int, dId: Int, moId: Int, customerName: String?) {
        self.mId = mId
        self.dId = dId
        self.moId = moId
        self.customerName = customerName
    }
    
    private func configureUI() {
        self.naviTitleLabel.text = customerName
        guard let mId = mId, let dId = dId, let moId = moId else { return }
        self.tableView.setupTableViewWith(mId: mId, dId: dId, moId: moId, targetViewController: self, delegate: self)
    }
    
    // MARK: Method
    @IBAction private func confirmButtonPress(_ sender: UIButton) {
        guard let model = orderSvcItemModel else { return }
        if ReservationManager.calculateServiceTotalValue(selectCategory: model.service.svcCategory, type: .Price) == 0 {
            SystemManager.showWarningBanner(title: LocalizedString("Lang_SD_023"), body: "")
            return
        }
        
        for category in model.service.svcCategory {
            if category.select ?? false, category.selectionType != .OnlySelect {
                if let selectSvcClass = category.selectSvcClass, (selectSvcClass.filter{ $0.name.count == 0 }.count) > 0 {
                    SystemManager.showWarningBanner(title: "\(LocalizedString("Lang_RV_016"))「\(category.name)」\(LocalizedString("Lang_DD_007"))", body: LocalizedString("Lang_RV_017"))
                    return
                }
            }
        }
        
        SystemManager.showTwoButtonAlertWith(alertTitle: LocalizedString("Lang_SD_022") + "？", alertMessage: nil, leftButtonTitle: LocalizedString("Lang_GE_060"), rightButtonTitle: LocalizedString("Lang_GE_056"), leftHandler: nil, rightHandler: { [unowned self] in
            self.apiSetMembersOrderSvcItems()
        })
    }
    
    // MARK: API
    private func apiSetMembersOrderSvcItems() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            ReservationManager.apiSetMembersOrderSvcItems(model: orderSvcItemModel!, success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_GE_021"), body: "")
                    self.hideLoading()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension ConfirmServiceContentViewController: ServiceItemsTableViewDelegate {
    
    func didUpdateSvcItem(model: OrderSvcItemsModel) {
        self.orderSvcItemModel = model
    }
    
    func didUpdateSvcCategory(array: [SvcCategoryModel]) {
        self.orderSvcItemModel?.service.svcCategory = array
    }
}

