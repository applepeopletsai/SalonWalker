//
//  NotificationListViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/12/20.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class NotificationListViewController: BaseViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var pushList = [PushListModel.PushDetailModel]()
    private var currentPage = 1
    private var totalPage = 1
    private var selectModel: PushListModel.PushDetailModel?
    private var menuView: MoreMenuView?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    override func networkDidRecover() {
        callAPI()
    }
    
    // MARK: Event Handler
    @IBAction private func menuButtonPress(_ sender: UIButton) {
        if menuView == nil {
            self.menuView = MoreMenuView.initWith(frame: CGRect(x:
                self.tableView.frame.maxX - 110 - 10, y:
                self.tableView.frame.minY - 10, width: 110, height: 90), delegate: self)
            self.view.addSubview(menuView!)
        } else {
            removeMenuView()
        }
    }
    
    // MARK: Method
    private func removeMenuView() {
        self.menuView?.removeFromSuperview()
        self.menuView = nil
    }
    
    private func callAPI() {
        setPushListRead()
        if pushList.count == 0 {
            if UserManager.sharedInstance.userIdentity == .consumer {
                apiGetMemberList()
            } else {
                apiGetOperationList()
            }
        }
    }
    
    private func setPushListRead() {
        guard let model = selectModel else { return }
        if model.pushStatus == 1 { return }
        self.apiPushListChgStatus(act: 1, pushModel: model)
    }
    
    private func handleChgStatusSuccess(act: Int, model: PushListModel.PushDetailModel?) {
        switch act {
        case 1,2:
            guard let model = model else { return }
            if let index = pushList.firstIndex(of: model) {
                if act == 1 {
                    pushList[index].pushStatus = 1
                } else {
                    pushList.remove(at: index)
                }
            }
            selectModel = nil
            break
        case 3:
            for i in 0..<pushList.count { pushList[i].pushStatus = 1 }
            break
        case 4:
            pushList.removeAll()
            break
        default: break
        }
        tableView.reloadData()
    }
    
    // MARK: API
    private func apiGetMemberList(showLoading: Bool = true) {
        if SystemManager.isNetworkReachable() {
            
            if showLoading { self.showLoading() }
            
            MemberManager.apiGetPushList(page: currentPage, success: { (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    
                    if let meta = model?.data?.meta {
                        self.totalPage = meta.totalPage
                    }
                    
                    if let list = model?.data?.pushList {
                        if self.currentPage == 1 {
                            self.pushList = list
                        } else {
                            self.pushList.append(contentsOf: list)
                        }
                    }
                    self.tableView.reloadData()
                } else {
                    self.endLoadingWith(model: model)
                }
                
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiGetOperationList(showLoading: Bool = true) {
        if SystemManager.isNetworkReachable() {
            
            if showLoading { self.showLoading() }
            
            OperatingManager.apiGetPushList(page: currentPage, success: { (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    
                    if let meta = model?.data?.meta {
                        self.totalPage = meta.totalPage
                    }
                    
                    if let list = model?.data?.pushList {
                        if self.currentPage == 1 {
                            self.pushList = list
                        } else {
                            self.pushList.append(contentsOf: list)
                        }
                    }
                    self.tableView.reloadData()
                } else {
                    self.endLoadingWith(model: model)
                }
                
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    // act -> 1:單筆已讀 | 2:單筆刪除 | 3:全部已讀 | 4:全部刪除
    private func apiPushListChgStatus(act: Int, pushModel: PushListModel.PushDetailModel?) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            if UserManager.sharedInstance.userIdentity == .consumer {
                MemberManager.apiPushListChgStatus(act: act, pushId: pushModel?.pushId, pushType: pushModel?.pushType, success: { (model) in
                    
                    if model?.syscode == 200 {
                        self.hideLoading()
                        self.handleChgStatusSuccess(act: act, model: pushModel)
                    } else {
                        self.endLoadingWith(model: model)
                    }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
                })
            } else {
                OperatingManager.apiPushListChgStatus(act: act, pushId: pushModel?.pushId, pushType: pushModel?.pushType, success: { (model) in
                    
                    if model?.syscode == 200 {
                        self.hideLoading()
                        self.handleChgStatusSuccess(act: act, model: pushModel)
                    } else {
                        self.endLoadingWith(model: model)
                    }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
                })
            }
        }
    }
}

extension NotificationListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pushList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NotificationListCell.self), for: indexPath) as! NotificationListCell
        cell.setupCellWith(model: pushList[indexPath.row])
        return cell
    }
}

extension NotificationListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        removeMenuView()
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: NotificationDetailViewController.self)) as! NotificationDetailViewController
        vc.setupVCWith(model: pushList[indexPath.row])
        self.navigationController?.pushViewController(vc, animated: true)
        self.selectModel = pushList[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if currentPage < totalPage, indexPath.row == pushList.count - 2 {
            currentPage += 1
            if UserManager.sharedInstance.userIdentity == .consumer {
                apiGetMemberList(showLoading: false)
            } else {
                apiGetOperationList(showLoading: false)
            }
        }
    }
}

extension NotificationListViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        removeMenuView()
    }
}

extension NotificationListViewController: MoreMenuViewDelegate {
    func allRead() {
        removeMenuView()
        apiPushListChgStatus(act: 3, pushModel: nil)
    }
    
    func allDelete() {
        removeMenuView()
        apiPushListChgStatus(act: 4, pushModel: nil)
    }
}
