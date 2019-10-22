//
//  CustomerReservationTableView.swift
//  SalonWalker
//
//  Created by Scott.Tsai on 2018/4/23.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

let kShouldReloadOrderRecord = "ShouldReloadOrderRecord"

// 設計師：客戶預約訂單；場地：設計師預約訂單
class CustomerReservationTableView: UITableView {
    
    private var dataArray = [OrderListModel.OrderList]()
    private var type: OperatingOrderRecordType = .WaitForRespond
    private var refreshControl_ = UIRefreshControl()
    private weak var targetVC: BaseViewController?
    
    private var currentPage: Int = 1
    private var totalPage: Int = 1
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Method
    func setupTableViewWith(type: OperatingOrderRecordType, targetViewController: BaseViewController) {
        self.type = type
        self.targetVC = targetViewController
    }
    
    func callAPI() {
        if dataArray.count == 0 {
            getData()
        }
        if refreshControl_.isRefreshing {
            shouldReloadData()
        }
    }
    
    private func getData() {
        if UserManager.sharedInstance.userIdentity == .designer {
            apiGetMemberOrderListByD()
        } else {
            apiGetDesignerOrderListByP()
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
        getData()
    }
    
    private func registerCell() {
        self.register(UINib(nibName: String(describing: CustomerReservationCell.self), bundle: nil), forCellReuseIdentifier: String(describing: CustomerReservationCell.self))
        self.register(UINib(nibName: String(describing: CustomerReservationCell_NoPrice.self), bundle: nil), forCellReuseIdentifier: String(describing: CustomerReservationCell_NoPrice.self))
    }
    
    private func handleSuccess(model: BaseModel<OrderListModel>?) {
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
    }
    
    // MARK: API
    // 設計師：客戶預約訂單
    private func apiGetMemberOrderListByD(showLoading: Bool = true) {
        if SystemManager.isNetworkReachable() {
            var status = 0
            switch type {
            case .WaitForRespond:
                status = 100
                break
            case .GetDeposit:
                status = 200
                break
            case .AlreadyCancel:
                status = 300
                break
            case .AlreadyDone:
                status = 500
                break
            default:
                debugPrint("=== 訂單狀態錯誤: \(type)")
                return
            }
            
            if showLoading { self.targetVC?.showLoading() }
            
            OrderDataManager.apiGetMemberOrderListByD(status: status, page: currentPage, success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    self.handleSuccess(model: model)
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
    
    // 場地：設計師預約訂單
    private func apiGetDesignerOrderListByP(showLoading: Bool = true) {
        if SystemManager.isNetworkReachable() {
            var status = 0
            switch type {
            case .AlreadyBook:
                status = 200
                break
            case .AlreadyCancel:
                status = 300
                break
            case .AlreadyDone:
                status = 500
                break
            default:
                debugPrint("=== 訂單狀態錯誤: \(type)")
                return
            }
            
            if showLoading { self.targetVC?.showLoading() }
            
            OrderDataManager.apiGetDesignerOrderListByP(status: status, page: currentPage, success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    self.handleSuccess(model: model)
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

extension CustomerReservationTableView: UITableViewDataSource, UITableViewDelegate {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if type == .WaitForRespond {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CustomerReservationCell_NoPrice.self), for: indexPath) as! CustomerReservationCell_NoPrice
            cell.setupCellWtihModel(dataArray[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CustomerReservationCell.self), for: indexPath) as! CustomerReservationCell
            cell.setupCellWith(model: dataArray[indexPath.row], indexPath: indexPath, delegate: self)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if type == .WaitForRespond {
            return 95
        } else {
            return 120
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 設計師-客戶預約訂單：待回覆、已收訂金、已取消、已完成
        // 場地-設計師預約訂單：已預訂、已取消、已完成
        if UserManager.sharedInstance.userIdentity == .designer {
            let vc = UIStoryboard(name: "OrderRecord", bundle: nil).instantiateViewController(withIdentifier: String(describing: DesignerReservationByConsumerDetailViewController.self)) as! DesignerReservationByConsumerDetailViewController
            vc.setupVCWith(moId: dataArray[indexPath.row].moId)
            self.targetVC?.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: OperatingReservationDetailViewController.self)) as! OperatingReservationDetailViewController
            vc.setupVCWith(doId: dataArray[indexPath.row].doId, orderDetailInfoModel: nil)
            self.targetVC?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == dataArray.count - 2 && currentPage < totalPage {
            currentPage += 1
            
            if UserManager.sharedInstance.userIdentity == .designer {
                apiGetMemberOrderListByD(showLoading: false)
            } else {
                apiGetDesignerOrderListByP(showLoading: false)
            }
        }
    }
}

extension CustomerReservationTableView: CustomerReservationCellDelegate {
    
    func commentButtonPressAtIndexPath(_ indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: ShowCommentViewController.self)) as! ShowCommentViewController
        vc.setupVCWith(model: dataArray[indexPath.row].evaluateStatus.evaluation!)
        self.targetVC?.navigationController?.pushViewController(vc, animated: true)
    }
}
