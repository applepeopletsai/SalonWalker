//
//  StoreHomePageViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/19.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class StoreHomePageViewController: BaseViewController {
    
    // MARK: Property
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: ProviderInfoCollectionView!
    @IBOutlet private weak var penaltyView: UIView!
    @IBOutlet private weak var penaltyViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var penaltyLabel: UILabel!
    @IBOutlet private weak var filterView: FilterView!
    
    private var filterModel: CityCodeModel.CityModel?
    private var providerListArray: [ProviderListModel]?
    private var designerListArray: [DesignerListModel]?
    private var currentPage = 1
    private var totalPage = 1
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTitle()
        configurePenaltyView()
        setupFilterView()
        setupCollectionView()
    }
    
    override func networkDidRecover() {
        callAPI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAccountStatus()
        callAPI()
    }
    
    // MARK: Method
    private func callAPI() {
        if ((providerListArray?.count ?? 0) == 0 && (designerListArray?.count ?? 0) == 0) || refreshControl.isRefreshing {
            apiGetProviderList()
        }
    }
    
    private func configureTitle() {
        if UserManager.sharedInstance.userIdentity == .store {
            self.titleLabel.text = LocalizedString("Lang_HM_046")
        }
    }
    
    private func configurePenaltyView() {
        if UserManager.sharedInstance.accountStatus == .suspend_temporary ||
            UserManager.sharedInstance.accountStatus == .suspend_permanent ||
            UserManager.sharedInstance.accountStatus == .waitForMarket {
            let labelText = (UserManager.sharedInstance.accountStatus == .waitForMarket) ? LocalizedString("Lang_HM_012") : UserManager.sharedInstance.penalty?.title
            self.penaltyLabel.text = labelText
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchPenaltyView))
            gestureRecognizer.numberOfTapsRequired = 1
            self.penaltyView.addGestureRecognizer(gestureRecognizer)
        } else {
            self.penaltyViewHeight.constant = 0
        }
    }
    
    private func setupFilterView() {
        filterView.setupFilterViewWith(targetVC: self, delegate: self)
    }
    
    private func setupCollectionView() {
        self.collectionView.setupCollectionViewWith(providerListArray: providerListArray, designerListArray: designerListArray, target: self)
        self.setupRefreshControlWith(scrollView: self.collectionView, action: #selector(refreshData), target: self)
    }
    
    @objc func refreshData() {
        self.currentPage = 1
        self.totalPage = 1
        self.apiGetProviderList()
    }
    
    @objc private func touchPenaltyView() {
        if UserManager.sharedInstance.accountStatus == .waitForMarket {
            SystemManager.changeTabBarSelectIndex(index: 3)
        } else {
            PresentationTool.showNoButtonAlertWith(image: UIImage(named: "img_pop_warning"), message: UserManager.sharedInstance.penalty!.msg, autoDismiss: false, completion: nil)
        }
    }
    
    private func searchProvider() {
        self.currentPage = 1
        self.apiGetProviderList()
    }
    
    // MARK: API
    private func apiGetProviderList(showLoading: Bool = true) {
        if SystemManager.isNetworkReachable() {
            
            if showLoading {
                self.showLoading()
            }
            
            let areaNameArray = filterModel?.area?.map({ $0.areaName ?? "" })
            
            HomeManager.apiGetProviderList(page: currentPage, pMax: 30, cityName: filterModel?.cityName, areaName: areaNameArray, keyWord: filterModel?.keyword, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    if let meta = model?.data?.meta {
                        self.totalPage = meta.totalPage
                    }
                    if let providerList = model?.data?.providerList {
                        if self.currentPage == 1 {
                            self.providerListArray = providerList
                        } else {
                            self.providerListArray?.append(contentsOf: providerList)
                        }
                    } else {
                        self.providerListArray = nil
                    }
                    
                    if let designerLit = model?.data?.designerList {
                        if self.currentPage == 1 {
                            self.designerListArray = designerLit
                        } else {
                            self.designerListArray?.append(contentsOf: designerLit)
                        }
                    } else {
                        self.designerListArray = nil
                    }
                    
                    self.collectionView.reloadData(providerListArray: self.providerListArray, designerListArray: self.designerListArray)
                    self.hideLoading()
                    self.removeMaskView()
                } else {
                    self.endLoadingWith(model: model)
                }
                self.refreshControl.endRefreshing()
            }, failure: { [unowned self] (error) in
                SystemManager.showErrorAlert(error: error)
                self.refreshControl.endRefreshing()
                self.removeMaskView()
            })
        }
    }
    
    private func apiEditFavProviderListWith(indexPath: IndexPath) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            let act = !(providerListArray?[indexPath.row].isFav ?? designerListArray?[indexPath.row].isFav ?? true) ? "add" : "del"
            
            HomeManager.apiEditFavProviderList(pId: providerListArray?[indexPath.row].pId, dId: designerListArray?[indexPath.row].dId, act: act, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    if UserManager.sharedInstance.userIdentity == .store {
                        let isFav = self.designerListArray?[indexPath.row].isFav ?? true
                        self.designerListArray?[indexPath.row].isFav = !isFav
                    } else if UserManager.sharedInstance.userIdentity == .designer {
                        let isFav = self.providerListArray?[indexPath.row].isFav ?? true
                        self.providerListArray?[indexPath.row].isFav = !isFav
                    }
                    let cell = self.collectionView.cellForItem(at: indexPath) as! ProviderInfoCollectionCell
                    cell.changeViewAnimation(isFav: self.providerListArray?[indexPath.row].isFav ?? self.designerListArray?[indexPath.row].isFav ?? false)
                    self.collectionView.reloadData(providerListArray: self.providerListArray, designerListArray: self.designerListArray, reloadTableView: false)
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiGetCityCode(_ success: actionClosure? = nil) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            SystemManager.apiGetCityCode(success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    if let cityCodeModel = model?.data {
                        SystemManager.saveCityCodeModel(cityCodeModel)
                        success?()
                    }
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func checkAccountStatus() {
        // 檢查帳號狀態
        if UserManager.sharedInstance.userIdentity == .designer {
            OperatingManager.apiGetDesignerInfo(success: { [weak self] (model) in
                if model?.syscode == 200 {
                    if let status = model?.data?.status {
                        UserManager.sharedInstance.accountStatus = AccountStatus(rawValue: status)
                    }
                    UserManager.sharedInstance.penalty = model?.data?.penalty
                    self?.configurePenaltyView()
                }
                }, failure: { _ in })
        } else {
            OperatingManager.apiGetProviderInfo(success: { [weak self] (model) in
                if model?.syscode == 200 {
                    if let status = model?.data?.status {
                        UserManager.sharedInstance.accountStatus = AccountStatus(rawValue: status)
                    }
                    UserManager.sharedInstance.penalty = model?.data?.penalty
                    self?.configurePenaltyView()
                }
                }, failure: { _ in })
        }
    }
}

extension StoreHomePageViewController: ProviderInfoCollectionViewDelegate {
    func didSelectItemAt(indexPath: IndexPath) {
        if UserManager.sharedInstance.userIdentity == .store {
            guard let dId = designerListArray?[indexPath.row].dId else { return }
            let vc = UIStoryboard(name: kStory_DesignerDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: DesignerDetailViewController.self)) as! DesignerDetailViewController
            vc.setupVCWith(dId: dId)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if UserManager.sharedInstance.userIdentity == .designer {
            guard let pId = providerListArray?[indexPath.row].pId else { return }
            let vc = UIStoryboard(name: kStory_StoreDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: StoreDetailViewController.self)) as! StoreDetailViewController
            vc.setupVCWith(pId: pId, type: .canBook)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func heartButtonClickAt(indexPath: IndexPath) {
        apiEditFavProviderListWith(indexPath: indexPath)
    }
    
    func collectionWillDisplayCellAt(indexPath: IndexPath) {
        let compareCount = providerListArray?.count ?? designerListArray?.count ?? 0
        if indexPath.item == compareCount - 3 && currentPage < totalPage {
            currentPage += 1
            apiGetProviderList(showLoading: false)
        }
    }
}

extension StoreHomePageViewController: FilterViewDelegate {
    
    func didPressFinishButton(_ model: CityCodeModel.CityModel?) {
        self.filterModel = model
        self.searchProvider()
    }
    
    func didPressSearchButton(_ model: CityCodeModel.CityModel?) {
        self.filterModel = model
        self.searchProvider()
    }
    
    func didSelectRecentSearch(_ model: CityCodeModel.CityModel?) {
        self.filterModel = model
        self.searchProvider()
    }
}
