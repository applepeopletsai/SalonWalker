//
//  OrderRecordTableView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/16.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

let kShouldReloadOrderRecord = "ShouldReloadOrderRecord"

class OrderRecordTableView: UITableView {
    
    private var dataArray = [OrderListModel.OrderList]()
    private var reloadType: ConsumerOrderRecordType?
    private weak var targetVC: BaseViewController?
    
    private var currentPage: Int = 1
    private var totalPage: Int = 1
    
    // MARK: Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = self
        self.delegate = self
        registerCell()
        addObser()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Method
    func setupTableViewWith(targetViewController: BaseViewController) {
        self.targetVC = targetViewController
    }
    
    func callAPIWithType(_ type: ConsumerOrderRecordType) {
        self.reloadType = type
        if dataArray.count == 0 {
            apiGetMemberOrderList(type: type)
        }
    }
    
    func resetDataWithType(_ type: ConsumerOrderRecordType) {
        self.reloadType = type
        self.currentPage = 1
        apiGetMemberOrderList(type: type)
    }
    
    private func addObser() {
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadData), name: NSNotification.Name(rawValue: kShouldReloadOrderRecord), object: nil)
    }
    
    // 更改訂單狀態時需要更新列表
    @objc private func shouldReloadData() {
        if let type = reloadType {
            currentPage = 1
            apiGetMemberOrderList(type: type)
        }
    }
    
    private func registerCell() {
        self.register(UINib(nibName: String(describing: OrderRecordCell.self), bundle: nil), forCellReuseIdentifier: String(describing: OrderRecordCell.self))
    }
    
    // MARK: API
    private func apiGetMemberOrderList(type: ConsumerOrderRecordType, showLoading: Bool = true) {
        if SystemManager.isNetworkReachable() {
            
            var status = 0
            switch type {
            case .PayDeposit_Wait:
                status = 100
                break
            case .PayDeposit_Confirm:
                status = 200
                break
            case .BackDeposit:
                status = 300
                break
            case .Penalty:
                status = 400
                break
            case .Finish:
                status = 500
                break
            }
            
            if showLoading { self.targetVC?.showLoading() }
            
            OrderDataManager.apiGetMemberOrderList(status: status, page: currentPage, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    if let totalPage = model?.data?.meta.totalPage {
                        self.totalPage = totalPage
                    }
                    if let orderList = model?.data?.orderList {
                        if self.currentPage == 1 {
                            self.dataArray = orderList
                        } else {
                            self.dataArray.append(contentsOf: orderList)
                        }
                    } else {
                        self.dataArray = []
                    }
                    self.reloadData()
                    self.targetVC?.hideLoading()
                } else {
                    self.targetVC?.endLoadingWith(model: model)
                }
                
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension OrderRecordTableView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: OrderRecordCell.self), for: indexPath) as! OrderRecordCell
        cell.setupCellWith(model: dataArray[indexPath.row], indexPath: indexPath, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let moId = dataArray[indexPath.row].moId else { return }
        let vc = UIStoryboard(name: kStory_ReserveDesigner, bundle: nil).instantiateViewController(withIdentifier: String(describing: ConsumerReservationDetailViewController.self)) as! ConsumerReservationDetailViewController
        vc.setupVCWith(moId: moId)
        self.targetVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == dataArray.count - 2 && currentPage < totalPage {
            currentPage += 1
            if let type = reloadType {
                apiGetMemberOrderList(type: type, showLoading: false)
            }
        }
    }
}

extension OrderRecordTableView: OrderRecordCellDelegate {
    
    func commentButtonPressAtIndexPath(_ indexPath: IndexPath) {
        if dataArray[indexPath.row].evaluateStatus.evaluation == nil {
            guard let dId = dataArray[indexPath.row].dId, let moId = dataArray[indexPath.row].moId else { return }
            let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: WriteCommentViewController.self)) as! WriteCommentViewController
            vc.setupVCWith(dId: dId, moId: moId)
            self.targetVC?.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: ShowCommentViewController.self)) as! ShowCommentViewController
            vc.setupVCWith(model: dataArray[indexPath.row].evaluateStatus.evaluation!)
            self.targetVC?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}


