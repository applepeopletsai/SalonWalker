//
//  RequireRecordViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class RequireRecordViewController: BaseViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var historyArray = [CustomerSvcHistoryModel.SvcHistory]()
    private var mId: Int?
    private var currentPage = 1
    private var totalPage = 1
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Method
    func setupVCWith(mId: Int?) {
        self.mId = mId
    }
    
    func callAPI() {
        if historyArray.count == 0 {
            apiGetHistory(showLoading: true)
        }
    }
    
    // MARK: API
    private func apiGetHistory(showLoading: Bool) {
        guard let mId = mId else { return }
        if SystemManager.isNetworkReachable() {
            if showLoading { self.showLoading() }
            
            CustomerManager.apiGetCustomerSvcHistory(mId: mId, page: currentPage, pMax: 50, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    
                    if let totalPage = model?.data?.meta.totalPage {
                        self.totalPage = totalPage
                    }
                    
                    if let historyArray = model?.data?.svcHistory {
                        if self.currentPage == 1 {
                            self.historyArray = historyArray
                        } else {
                            self.historyArray.append(contentsOf: historyArray)
                        }
                    } else {
                        self.historyArray = []
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

extension RequireRecordViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RequireRecordTableViewCell.self), for: indexPath) as! RequireRecordTableViewCell
        cell.setupCellWithModel(historyArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: ServiceContentViewController.self)) as! ServiceContentViewController
        var svcContent = historyArray[indexPath.row].svcContent
        svcContent.svcCategory = svcContent.svcCategory.map{
            var model = $0
            model.selectSvcClass = $0.svcClass
            return model
        }
        vc.setupVCWithModel(svcContent)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == historyArray.count - 3 && currentPage < totalPage {
            currentPage += 1
            apiGetHistory(showLoading: false)
        }
    }
}
