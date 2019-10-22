//
//  ServiceLocationTableView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/13.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum ServiceLocationViewType {
    // 服務設定中的服務地點、新增服務地點、消費者預約設計師
    case SetServiceLocation, AddServiceLocation, ReserveDesigner
}

enum SelectType {
    case Single, Multiple
}

protocol ServiceLocationTableViewDelegate: class {
    func updateSelectSvcPlaceIdArray(_ selectPIdArray: [Int])
    func deleteSvcPlaceSuccess()
    func insertSvcPlaceSuccess()
    func didSelectSvcPlace(model: SvcPlaceModel)
}

class ServiceLocationTableView: UITableView {

    private var svcPlaceArray = [SvcPlaceModel]()
    private var selectSvcPIdArray = [Int]()
    private var viewType: ServiceLocationViewType = .SetServiceLocation
    private var cellType: ServiceLocationCellType = .normal
    private var selectType: SelectType = .Multiple
    
    private var placeKeyWord: String?
    private var currentPage: Int = 1
    private var totalPage: Int = 1
    
    private var dId: Int?
    private var orderDate: String?
    private var startTime: String?
    private var svcTimeTotal: Int?
    
    private weak var targetVC: BaseViewController?
    private weak var serviceLocationTableViewDelegate: ServiceLocationTableViewDelegate?
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.dataSource = self
        registerCell()
    }
    
    // MAKR: Method
    func setupTableViewWith(viewType: ServiceLocationViewType, cellType: ServiceLocationCellType, targetViewController: BaseViewController, delegate: ServiceLocationTableViewDelegate) {
        self.viewType = viewType
        self.cellType = cellType
        self.targetVC = targetViewController
        self.serviceLocationTableViewDelegate = delegate
    }
    
    func setupTableViewWith(viewType: ServiceLocationViewType, cellType: ServiceLocationCellType, dId: Int, orderDate: String, startTime: String, svcTimeTotal:Int, targetViewController: BaseViewController, delegate: ServiceLocationTableViewDelegate) {
        self.selectType = .Single
        self.dId = dId
        self.orderDate = orderDate
        self.startTime = startTime
        self.svcTimeTotal = svcTimeTotal
        self.viewType = viewType
        self.cellType = cellType
        self.targetVC = targetViewController
        self.serviceLocationTableViewDelegate = delegate
    }
    
    func changeType(cellType: ServiceLocationCellType) {
        self.cellType = cellType
        for cell in self.visibleCells {
            if let cell = cell as? ServiceLocationCell {
                cell.animateTickButtonImage(cellType: cellType)
            }
        }
    }
    
    func callAPI() {
        if svcPlaceArray.count == 0 {
            getData(showLoading: true)
        }
    }
    
    func callAPIWithKeyword(_ keyword: String) {
        placeKeyWord = keyword
        reCallAPI()
    }
    
    func reCallAPI() {
        currentPage = 1
        getData(showLoading: true)
    }
    
    func deleteSelectSvcPlace() {
        apiDelSvcPlace()
    }
    
    func insertSelectSvcPlace() {
        apiInsertSvcPlace()
    }
    
    private func getData(showLoading: Bool) {
        switch viewType {
        case .SetServiceLocation:
            apiGetSetSvcPlace(showLoading: true)
            break
        case .AddServiceLocation:
            apiGetSvcPlace_Designer(showLoading: true)
            break
        case .ReserveDesigner:
            apiGetSvcPlace_Consumer(showLoading: true)
            break
        }
    }
    
    private func handlerAPISuccess(with model: BaseModel<SvcPlaceInfoModel>?) {
        if model?.syscode == 200 {
            if let totalPage = model?.data?.meta.totalPage {
                self.totalPage = totalPage
            }
            if var svcPlace = model?.data?.svcPlace {
                svcPlace = svcPlace.enumerated().map{ arg in
                    var model = arg.element
                    model.select = self.selectSvcPIdArray.contains(model.pId)
                    return model
                }
                if self.currentPage == 1 {
                    self.svcPlaceArray = svcPlace
                } else {
                    self.svcPlaceArray.append(contentsOf: svcPlace)
                }
            } else {
                self.svcPlaceArray = []
            }
            self.reloadData()
            self.targetVC?.hideLoading()
        } else {
            self.targetVC?.endLoadingWith(model: model)
        }
    }
    
    private func registerCell() {
        self.register(UINib(nibName: "ServiceLocationCell", bundle: nil), forCellReuseIdentifier: String(describing: ServiceLocationCell.self))
    }
    
    // MARK: API
    private func apiGetSetSvcPlace(showLoading: Bool) {
        if SystemManager.isNetworkReachable() {
            if showLoading { self.targetVC?.showLoading() }
            DesignerServiceManager.apiGetSetSvcPlace(page: currentPage, pMax: 50, placeKeyWord: placeKeyWord, success: { [unowned self] (model) in
                self.handlerAPISuccess(with: model)
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiGetSvcPlace_Designer(showLoading: Bool) {
        if SystemManager.isNetworkReachable() {
            if showLoading { self.targetVC?.showLoading() }
            DesignerServiceManager.apiGetSvcPlace(placeKeyWord: placeKeyWord, success: { [unowned self] (model) in
                self.handlerAPISuccess(with: model)
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiGetSvcPlace_Consumer(showLoading: Bool) {
        if SystemManager.isNetworkReachable() {
            guard let dId = dId, let orderDate = orderDate, let startTime = startTime, let svcTimeTotal = svcTimeTotal else { return }
            if showLoading { self.targetVC?.showLoading() }
            
            ReservationManager.apiGetSvcPlace(dId: dId, orderDate: orderDate, startTime: startTime, svcTimeTotal: svcTimeTotal, page: currentPage, pMax: 50, placeKeyWord: placeKeyWord, success: { (model) in
                self.handlerAPISuccess(with: model)
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiInsertSvcPlace() {
        if SystemManager.isNetworkReachable() {
            self.targetVC?.showLoading()
            DesignerServiceManager.apiInsertSvcPlace(pId: selectSvcPIdArray, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_GE_022"), body: "")
                    self.targetVC?.hideLoading()
                    self.serviceLocationTableViewDelegate?.insertSvcPlaceSuccess()
                } else {
                    self.targetVC?.endLoadingWith(model: model)
                }
                },failure:  { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiDelSvcPlace() {
        if SystemManager.isNetworkReachable() {
            self.targetVC?.showLoading()
            DesignerServiceManager.apiDelSvcPlace(pId: selectSvcPIdArray, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_GE_021"), body: "")
                    self.svcPlaceArray = self.svcPlaceArray.filter{ !self.selectSvcPIdArray.contains($0.pId) }
                    self.selectSvcPIdArray.removeAll()
                    self.reloadData()
                    self.targetVC?.hideLoading()
                    self.serviceLocationTableViewDelegate?.deleteSvcPlaceSuccess()
                } else {
                    self.targetVC?.endLoadingWith(model: model)
                }
                },failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension ServiceLocationTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return svcPlaceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ServiceLocationCell.self), for: indexPath) as! ServiceLocationCell
        cell.setupCellWith(model: svcPlaceArray[indexPath.row], indexPath: indexPath, cellType: cellType, delegate: self)
        return cell
    }
}

extension ServiceLocationTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: kStory_StoreDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: StoreDetailViewController.self)) as! StoreDetailViewController
        vc.setupVCWith(pId: svcPlaceArray[indexPath.row].pId, type: .onlyCheck)
        let naviVC = UINavigationController(rootViewController: vc)
        naviVC.isNavigationBarHidden = true
        self.targetVC?.present(naviVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == svcPlaceArray.count - 3 && currentPage < totalPage {
            currentPage += 1
            getData(showLoading: false)
        }
    }
}

extension ServiceLocationTableView: ServiceLocationCellDelegate {
    
    func tickButtonPress(at indexPath: IndexPath) {
        
        if selectType == .Single {
            self.svcPlaceArray = self.svcPlaceArray.map{ (model) -> SvcPlaceModel in
                var m = model
                m.select = false
                return m
            }
            self.svcPlaceArray[indexPath.row].select = true
            self.serviceLocationTableViewDelegate?.didSelectSvcPlace(model: self.svcPlaceArray[indexPath.row])
        } else {
            let pId = self.svcPlaceArray[indexPath.row].pId
            if let index = selectSvcPIdArray.index(of: pId) {
                self.selectSvcPIdArray.remove(at: index)
            } else {
                self.selectSvcPIdArray.append(pId)
            }
            self.svcPlaceArray[indexPath.row].select = !self.svcPlaceArray[indexPath.row].select!
        }
        self.serviceLocationTableViewDelegate?.updateSelectSvcPlaceIdArray(self.selectSvcPIdArray)
        self.reloadData()
    }
}
