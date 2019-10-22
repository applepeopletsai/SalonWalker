//
//  DesignerInfoTableView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

let kGoToRankingVC = "kGoToRankingVC"

@objc protocol DesignerInfoTableViewDelegate: class {
    @objc optional func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    @objc optional func didUpdateDesignerList(designerListCount: Int)
}

enum DesignerInfoTableViewType {
    // 熱門推薦,窩藏名單,全站排行,自訂
    case PopularRecommend, HarborList, FullSiteRanking, Custom
}

struct CustomSearchDesignerModel {
    var selectCity: CityCodeModel.CityModel?
    var selectArea: CityCodeModel.AreaModel?
    var lat: Double?
    var lng: Double?
    var sex: String?
    var evaluationAvgStart: Int
    var evaluationAvgEnd: Int
    var experienceStart: Int
    var experienceEnd: Int
    var license: String?
}

class DesignerInfoTableView: UITableView {

    private var designerList = [DesignerListModel]()
    private var currentPage = 1
    private var totalPage = 1
    private var type: DesignerInfoTableViewType = .PopularRecommend
    private var refreshControl_ = UIRefreshControl()
    private var filterModel: CityCodeModel.CityModel?
    private var customSerachDesignerModel: CustomSearchDesignerModel?
    private weak var targetVC: BaseViewController?
    private weak var designerInfoTableViewDelegate: DesignerInfoTableViewDelegate?
    
    @IBInspectable private var showNoFavCell: Bool = false
    @IBInspectable private var showMessage: Bool = true
    
    private var cellIdentifier: String {
        // 第一階段沒有訊息按鈕 by Daniel 2018/05/08
//        if showMessage {
//            return "DesignerInfoCell"
//        } else {
            return "DesignerInfoCell-NoMessage"
//        }
    }
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        addObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Method
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUIAfterLoginout), name: NSNotification.Name(rawValue: kRefreshUIAfterLoginout), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUIAfterLoginout), name: NSNotification.Name(rawValue: kAPISyscode_501), object: nil)
    }
    
    @objc private func refreshUIAfterLoginout() {
        callAPI(forceRefresh: true)
    }
    
    func setupTableViewWith(designerList: [DesignerListModel], delegate: DesignerInfoTableViewDelegate?) {
        self.designerList = designerList
        self.designerInfoTableViewDelegate = delegate
        self.reloadData()
    }
    
    func setupTableViewWith(targetViewController: BaseViewController, tableViewType: DesignerInfoTableViewType, delegate: DesignerInfoTableViewDelegate? = nil) {
        self.targetVC = targetViewController
        self.type = tableViewType
        self.designerInfoTableViewDelegate = delegate
        self.configureTableView()
    }
    
    func callAPI(forceRefresh: Bool = false) {
        if !UserManager.isLoginSalonWalker() {
            if self.type == .PopularRecommend {
                if self.designerList.count == 0 {
                    getData(updateLocation: true)
                } else if forceRefresh {
                    refreshData()
                }
            }
        } else {
            if self.designerList.count == 0 {
                getData(updateLocation: true)
            } else {
                if self.refreshControl_.isRefreshing || forceRefresh {
                    refreshData()
                }
            }
        }
    }
    
    func getTopDesignerWith(filterModel: CityCodeModel.CityModel?) {
        self.currentPage = 1
        self.filterModel = filterModel
        self.apiGetTopDesignerList()
    }
    
    func getSpDesignerWith(model: CustomSearchDesignerModel) {
        self.currentPage = 1
        self.customSerachDesignerModel = model
        self.apiGetSpDesignerList()
    }
    
    private func configureTableView() {
        self.dataSource = self
        self.delegate = self
        self.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        if showNoFavCell {
            self.register(UINib(nibName: "DesignerInfoCell-NoFav", bundle: nil), forCellReuseIdentifier: "DesignerInfoCell-NoFav")
        }
        self.refreshControl_.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.addSubview(refreshControl_)
    }
    
    private func getData(showLoading: Bool = true, updateLocation: Bool = false) {
        switch type {
        case .PopularRecommend:
            apiGetHotDesignerList(showLoading: showLoading, updateLocation: updateLocation)
            break
        case .HarborList:
            apiGetFavDesignerList(showLoading: showLoading)
            break
        case .FullSiteRanking:
            apiGetTopDesignerList(showLoading: showLoading, updateLocation: updateLocation)
            break
        case .Custom:
            apiGetSpDesignerList(showLoading: showLoading)
            break
        }
    }
    
    @objc func refreshData() {
        self.currentPage = 1
        self.getData()
    }
    
    private func handleSuccess(model: BaseModel<HotDesignerListModel>?) {
        self.refreshControl_.endRefreshing()
        if model?.syscode == 200 {
            if let totalPage = model?.data?.meta.totalPage {
                self.totalPage = totalPage
            }
            if let designerList = model?.data?.designerList {
                if self.currentPage == 1 {
                    self.designerList = designerList
                } else {
                    self.designerList.append(contentsOf: designerList)
                }
            } else {
                self.designerList = []
            }
            self.reloadData()
            self.targetVC?.removeMaskView()
            self.targetVC?.hideLoading()
        } else {
            self.targetVC?.endLoadingWith(model: model)
        }
    }
    
    private func handleFailure(error: Error?) {
        self.targetVC?.removeMaskView()
        self.refreshControl_.endRefreshing()
        SystemManager.showErrorAlert(error: error)
    }
    
    // MARK: API
    // 熱門推薦
    private func apiGetHotDesignerList(showLoading: Bool = true, updateLocation: Bool = false) {
        if SystemManager.isNetworkReachable() {
            if updateLocation {
                LocationManager.getLocationWithTarget(self)
            } else {
                if showLoading { self.targetVC?.showLoading() }
                let userLocation = LocationManager.userLastLocation().coordinate
                
                HomeManager.apiGetHotDesignerList(lat: userLocation.latitude, lng: userLocation.longitude, page: currentPage, pMax: 50, success: { [weak self] (model) in
                    self?.handleSuccess(model: model)
                    }, failure: { [weak self] (error) in
                        self?.handleFailure(error: error)
                })
            }
        }
    }
    
    // 窩藏名單
    private func apiGetFavDesignerList(showLoading: Bool = true, updateLocation: Bool = false) {
        if SystemManager.isNetworkReachable() {
            if updateLocation {
                LocationManager.getLocationWithTarget(self)
            } else {
                if showLoading { self.targetVC?.showLoading() }
                let userLocation = LocationManager.userLastLocation().coordinate
                
                HomeManager.apiGetFavDesignerList(lat: userLocation.latitude, lng: userLocation.longitude, page: currentPage, pMax: 50, success: { [weak self] (model) in
                    self?.handleSuccess(model: model)
                    }, failure: { [weak self] (error) in
                        self?.handleFailure(error: error)
                })
            }
        }
    }
    
    // 全站排行
    private func apiGetTopDesignerList(showLoading: Bool = true, updateLocation: Bool = false) {
        if updateLocation {
            LocationManager.getLocationWithTarget(self)
        } else {
            if SystemManager.isNetworkReachable() {
                if showLoading { self.targetVC?.showLoading() }
                let areaNameArray = filterModel?.area?.map({ $0.areaName ?? "" })
                let userLocation = LocationManager.userLastLocation().coordinate
                
                HomeManager.apiGetTopOrNearbyDesignerList(lat: userLocation.latitude, lng: userLocation.longitude, page: currentPage, pMax: 50, cityName: filterModel?.cityName, areaName: areaNameArray, cons: 2, keyWord: filterModel?.keyword, success: { [weak self] (model) in
                    self?.handleSuccess(model: model)
                    self?.designerInfoTableViewDelegate?.didUpdateDesignerList?(designerListCount: self?.designerList.count ?? 0)
                    }, failure: { [weak self] (error) in
                        self?.handleFailure(error: error)
                })
            }
        }
    }
    
    // 自訂
    private func apiGetSpDesignerList(showLoading: Bool = true) {
        guard let model = customSerachDesignerModel else { return }
        
        if SystemManager.isNetworkReachable() {
            if showLoading {
//                self.targetVC?.addMaskView()
                self.targetVC?.showLoading()
            }
            
            HomeManager.apiGetSpDesignerList(page: currentPage, pMax: 50, model: model, success: { [weak self] (model) in
                self?.handleSuccess(model: model)
                self?.designerInfoTableViewDelegate?.didUpdateDesignerList?(designerListCount: self?.designerList.count ?? 0)
                }, failure: { [weak self] (error) in
                    self?.handleFailure(error: error)
            })
        }
    }
    
    private func apiEditFavDesignerListAt(_ indexPath: IndexPath) {
        if SystemManager.isNetworkReachable() {
            self.targetVC?.showLoading()
            
            let ouId = self.designerList[indexPath.row].ouId
            let act = (self.designerList[indexPath.row].isFav) ? "del" : "add"
            let cell = self.cellForRow(at: indexPath) as! DesignerInfoCell
            HomeManager.apiEditFavDesignerList(ouId: ouId, act: act, success: { (model) in
                
                if model?.syscode == 200 {
                    self.designerList[indexPath.row].isFav = !self.designerList[indexPath.row].isFav
                    cell.changeViewAnimation(isFav: self.designerList[indexPath.row].isFav)
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

extension DesignerInfoTableView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showNoFavCell && designerList.count == 0 {
            return 1
        }
        return designerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if showNoFavCell && designerList.count == 0 {
           let cell = tableView.dequeueReusableCell(withIdentifier: "DesignerInfoCell-NoFav", for: indexPath) as! DesignerInfoCell_NoFav
            cell.delegate = self
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DesignerInfoCell
        cell.layoutIfNeeded()
        cell.setupCellWith(model: designerList[indexPath.row], indexPath: indexPath, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if showNoFavCell && designerList.count == 0 {
            return screenHeight - 44 - 49 - UIApplication.shared.statusBarFrame.size.height
        }
        return 190
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is DesignerInfoCell {
            if indexPath.row == designerList.count - 2 && currentPage < totalPage {
                currentPage += 1
                getData(showLoading: false)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if designerList.count != 0 {
            let vc = UIStoryboard(name: kStory_DesignerDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: DesignerDetailViewController.self)) as! DesignerDetailViewController
            vc.setupVCWith(dId: designerList[indexPath.row].dId)
            self.targetVC?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.designerInfoTableViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}

extension DesignerInfoTableView: DesignerInfoCellDelegate {
    
    func messageButtonPressAt(_ indexPath: IndexPath) {}
    
    func reservationButtonPressAt(_ indexPath: IndexPath) {
        let m = designerList[indexPath.row]
        let model = DesignerDetailModel(ouId: m.ouId, dId: m.dId, isRes: m.isRes, isTop: m.isTop, isFav: m.isFav, nickName: m.nickName, cityName: m.cityName ?? "", areaName: m.areaName ?? "", experience: m.experience, position: "", characterization: "", langName: m.langName ?? "", evaluationAve: m.evaluationAve, evaluationTotal: m.evaluationTotal, favTotal: 0, headerImgUrl: m.headerImgUrl, licenseImg: nil, coverImg: [], cautionTotal: 0, missTotal: 0, svcPlace: nil, paymentType: nil, svcCategory: nil, works: nil, customer: nil, openHour: nil)
        let vc = UIStoryboard(name: kStory_ReserveDesigner, bundle: nil).instantiateViewController(withIdentifier: String(describing:ReserveDesignerViewController.self)) as! ReserveDesignerViewController
        vc.setupVCWith(model: model)
        self.targetVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func favoriteButtonPressAt(_ indexPath: IndexPath) {
        apiEditFavDesignerListAt(indexPath)
    }
}

extension DesignerInfoTableView: DesignerInfoCell_NoFavDelegate {
    
    func findDesignerButtonPress() {
        SystemManager.changeTabBarSelectIndex(index: 1)
        NotificationCenter.default.post(name: NSNotification.Name(kGoToRankingVC), object: nil)
    }
}

extension DesignerInfoTableView: LocationManagerDelegate {
    
    func locationDidUpdateWithCoordinate(lat: Double, lng: Double) {
//        apiGetTopDesignerList()
        getData()
    }
    
    func didCancelAllowGPS() {
//        apiGetTopDesignerList()
        getData()
    }
}
