//
//  MyCustomerListTableView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/15.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol MyCustomerListTableViewDelegate: class {
    func updateSelectCustomerIdArray(selectMIdArray: [Int])
    func deleteCustomerSuccess()
    func didSelectCustomer(model: CustomerListModel.CustomerListInfo)
}

class MyCustomerListTableView: UITableView {

    private var customerListArray = [CustomerListModel.CustomerListInfo]()
    private var selectCustomerMIdArray = [Int]()
    private var keyword: String?
    private var currentPage: Int = 1
    private var totalPage: Int = 1
    private var type: StatusButtonType = .edit
    
    private weak var targetVC: BaseViewController?
    private weak var myCustomerListTableViewDelegate: MyCustomerListTableViewDelegate?
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = self
        self.delegate = self
        
        registerCell()
    }
    
    // MARK: Method
    private func registerCell() {
        self.register(UINib(nibName: String(describing: MyCustomerTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: MyCustomerTableViewCell.self))
    }
    
    func setupTableViewWith(type: StatusButtonType, targetViewController: BaseViewController, delegate: MyCustomerListTableViewDelegate) {
        self.type = type
        self.targetVC = targetViewController
        self.myCustomerListTableViewDelegate = delegate
    }
    
    func changeType(type: StatusButtonType) {
        self.type = type
        for cell in self.visibleCells {
            if let cell = cell as? MyCustomerTableViewCell {
                cell.animateTickButtonImage(type: type)
            }
        }
    }
    
    func deleteSelectCustomer() {
        apiDeleteCustomerList()
    }
    
    func callAPI() {
        if customerListArray.count == 0 {
            apiGetCustomerList(showLoading: true)
        }
    }
    
    func callAPIWithKeyword(_ keyword: String) {
        self.keyword = keyword
        reCallAPI()
    }
    
    private func reCallAPI() {
        currentPage = 1
        apiGetCustomerList(showLoading: true)
    }
    
    // MARK: API
    private func apiGetCustomerList(showLoading: Bool) {
        if SystemManager.isNetworkReachable() {
            if showLoading { self.targetVC?.showLoading() }
            
            CustomerManager.apiGetCustomerList(page: currentPage, keyword: keyword, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    if let totalPage = model?.data?.meta.totalPage {
                        self.totalPage = totalPage
                    }
                    if var customerList = model?.data?.customerList {
                        customerList = customerList.enumerated().map{ arg in
                            var model = arg.element
                            model.select = self.selectCustomerMIdArray.contains(model.mId)
                            return model
                        }
                        if self.currentPage == 1 {
                            self.customerListArray = customerList
                        } else {
                            self.customerListArray.append(contentsOf: customerList)
                        }
                    } else {
                        self.customerListArray = []
                    }
                    self.reloadData()
                    self.targetVC?.hideLoading()
                } else {
                    self.targetVC?.endLoadingWith(model: model)
                }
                }, failure: { (error) in
                    SystemManager.hideLoading()
            })
        }
    }
    
    private func apiDeleteCustomerList() {
        if SystemManager.isNetworkReachable() {
            self.targetVC?.showLoading()
            
            CustomerManager.apiDeleteCustomerList(mId: selectCustomerMIdArray, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_GE_021"), body: "")
                    self.customerListArray = self.customerListArray.filter{  !self.selectCustomerMIdArray.contains($0.mId)}
                    self.selectCustomerMIdArray.removeAll()
                    self.reloadData()
                    self.targetVC?.hideLoading()
                    self.myCustomerListTableViewDelegate?.deleteCustomerSuccess()
                } else {
                    self.targetVC?.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension MyCustomerListTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyCustomerTableViewCell.self), for: indexPath) as! MyCustomerTableViewCell
        cell.setupCellWith(model: customerListArray[indexPath.row], type: type)
        return cell
    }
}

extension MyCustomerListTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if type == .edit {
            self.myCustomerListTableViewDelegate?.didSelectCustomer(model: customerListArray[indexPath.row])
        } else {
            let mId = customerListArray[indexPath.row].mId
            if let index = selectCustomerMIdArray.index(of: mId) {
                selectCustomerMIdArray.remove(at: index)
            } else {
                selectCustomerMIdArray.append(mId)
            }
            customerListArray[indexPath.row].select = !customerListArray[indexPath.row].select!
            self.myCustomerListTableViewDelegate?.updateSelectCustomerIdArray(selectMIdArray: selectCustomerMIdArray)
            self.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == customerListArray.count - 2 && currentPage < totalPage {
            currentPage += 1
            apiGetCustomerList(showLoading: false)
        }
    }
}

