//
//  ConsumeRecordViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ConsumeRecordViewController: BaseViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var mId: Int?
    private var avgPricesModel: CustomerPayHistoryModel.AvgPrices?
    private var payHistoryArray = [CustomerPayHistoryModel.SvcPayHistory]()
    private var currentPage = 1
    private var totalPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Method
    func callAPI() {
        if avgPricesModel == nil && payHistoryArray.count == 0 {
            apiGetCustomerPayHistory(showLoading: true)
        }
    }
    
    func setupVCWith(mId: Int?) {
        self.mId = mId
    }
    
    // MARK: API
    private func apiGetCustomerPayHistory(showLoading: Bool) {
        guard let mId = mId else { return }
        
        if SystemManager.isNetworkReachable() {
            if showLoading { self.showLoading() }
            
            CustomerManager.apiGetCustomerPayHistory(mId: mId, page: currentPage, pMax: 50, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    if let totalPage = model?.data?.meta.totalPage {
                        self.totalPage = totalPage
                    }
                    
                    if let svcPayHistory = model?.data?.svcPayHistory {
                        self.avgPricesModel = model?.data?.avgPrices
                        if self.currentPage == 1 {
                            self.payHistoryArray = svcPayHistory
                        } else {
                           self.payHistoryArray.append(contentsOf: svcPayHistory)
                        }
                    } else {
                        self.payHistoryArray = []
                    }
                    
                    self.tableView.reloadData()
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

extension ConsumeRecordViewController: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (avgPricesModel != nil ? 1 : 0) + payHistoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0, avgPricesModel != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AverageCostTableViewCell.self), for: indexPath) as! AverageCostTableViewCell
            cell.setupCellWith(model: avgPricesModel!)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ConsumeRecordTableViewCell.self), for: indexPath) as! ConsumeRecordTableViewCell
            let index = (avgPricesModel != nil) ? indexPath.row - 1 : indexPath.row
            cell.setupCellWtih(model: payHistoryArray[index])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.row == 0 && avgPricesModel != nil) ? 150 : 55
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == payHistoryArray.count - 3 && currentPage < totalPage {
            currentPage += 1
            apiGetCustomerPayHistory(showLoading: false)
        }
    }
}
