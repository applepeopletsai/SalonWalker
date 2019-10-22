//
//  CourtReservationTableView.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/24.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class SiteReservationTableView: UITableView {

    private var dataArray = [OrderListModel.OrderList]()
    private var type: OperatingOrderRecordType = .AlreadyBook
    private var refreshControl_ = UIRefreshControl()
    private weak var targetVC: BaseViewController?

    private var currentPage: Int = 1
    private var totalPage: Int = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupTableViewWith(type: OperatingOrderRecordType, targetViewController: BaseViewController) {
        self.type = type
        self.targetVC = targetViewController
    }
    
    func callAPI() {
        if self.dataArray.count == 0 {
            apiGetDesignerOrderList()
        }
        if refreshControl_.isRefreshing {
            shouldReloadData()
        }
    }
    
    private func configure() {
        self.delegate = self
        self.dataSource = self
        self.refreshControl_.addTarget(self, action: #selector(shouldReloadData), for: .valueChanged)
        self.addSubview(refreshControl_)
        registerCell()
        addObser()
    }
    
    private func addObser() {
        // 更改訂單狀態時需要更新列表
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadData), name: NSNotification.Name(rawValue: kShouldReloadOrderRecord), object: nil)
    }
    
    @objc private func shouldReloadData() {
        currentPage = 1
        apiGetDesignerOrderList()
    }
    
    private func registerCell() {
        self.register(UINib(nibName: String(describing: SiteReservationCell.self), bundle: nil), forCellReuseIdentifier: String(describing: SiteReservationCell.self))
        self.register(UINib(nibName: String(describing: SiteReservationCell_NoPrice.self), bundle: nil), forCellReuseIdentifier: String(describing: SiteReservationCell_NoPrice.self))
    }
    
    // MARK: API
    private func apiGetDesignerOrderList(showLoading: Bool = true) {
        if SystemManager.isNetworkReachable() {
            var status = 0
            switch type {
            case .AlreadyBook:
                status = 200
                break
            case .BackDeposit:
                status = 300
                break
            case .AlreadyPenalty:
                status = 400
                break
            case .AlreadyDone:
                status = 500
                break
            default:
                debugPrint("=== 訂單狀態錯誤: \(type)")
                return
            }
            
            if showLoading { self.targetVC?.showLoading() }
            
            OrderDataManager.apiGetDesignerOrderList(status: status, page: currentPage, success: { [unowned self] (model) in
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
                self.refreshControl_.endRefreshing()
            }, failure: { [unowned self] (error) in
                self.refreshControl_.endRefreshing()
                SystemManager.showErrorAlert(error: error)
            })
        }
    }    
}

extension SiteReservationTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if type == .AlreadyBook {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SiteReservationCell_NoPrice.self), for: indexPath) as! SiteReservationCell_NoPrice
            cell.setupCellWith(model: dataArray[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SiteReservationCell.self), for: indexPath) as! SiteReservationCell
            cell.setupCellWith(model: dataArray[indexPath.row], indexPath: indexPath, delegate: self)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (type == .AlreadyBook) ? 120 : 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: OperatingReservationDetailViewController.self)) as! OperatingReservationDetailViewController
        vc.setupVCWith(doId: dataArray[indexPath.row].doId, orderDetailInfoModel: nil)
        self.targetVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == dataArray.count - 2 && currentPage < totalPage {
            currentPage += 1
            apiGetDesignerOrderList(showLoading: false)
        }
    }
}

extension SiteReservationTableView: SiteReservationCellDelegate {
    
    func commentButtonPressAtIndexPath(_ indexPath: IndexPath) {
        if dataArray[indexPath.row].evaluateStatus.evaluation == nil {
            guard let pId = dataArray[indexPath.row].pId, let doId = dataArray[indexPath.row].doId else { return }
            let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: WriteCommentViewController.self)) as! WriteCommentViewController
            vc.setupVCWith(pId: pId, doId: doId)
            self.targetVC?.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: ShowCommentViewController.self)) as! ShowCommentViewController
            vc.setupVCWith(model: dataArray[indexPath.row].evaluateStatus.evaluation!)
            self.targetVC?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

