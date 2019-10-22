//
//  MyHomeWallViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class MyHomeWallViewController: BaseViewController {
    
    //MARK: IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: ProviderInfoCollectionView!
    
    private var providerListArray: [ProviderListModel]?
    private var designerListArray: [DesignerListModel]?
    private var currentPage = 1
    private var totalPage = 1
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
        configureTitle()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    override func networkDidRecover() {
        callAPI()
    }
    
    // MARK: Method
    private func callAPI() {
        if (providerListArray?.count ?? 0) == 0 &&
            (designerListArray?.count ?? 0) == 0 {
            apiGetFavProviderListWithShowLoading(true)
        }
        if refreshControl.isRefreshing {
            refreshData()
        }
    }
    
    private func configureTitle() {
        if UserManager.sharedInstance.userIdentity == .store {
            self.titleLabel.text = LocalizedString("Lang_AC_074")
        }
    }
    
    private func setupCollectionView() {
        self.collectionView.setupCollectionViewWith(providerListArray: providerListArray, designerListArray: designerListArray, target: self)
        self.setupRefreshControlWith(scrollView: self.collectionView, action: #selector(refreshData),target: self)
    }
    
    @objc func refreshData() {
        self.currentPage = 1
        self.totalPage = 1
        self.apiGetFavProviderListWithShowLoading(true)
    }
    
    //MARK: API
    private func apiEditFavProviderListWith(indexPath: IndexPath ) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            let act = !(providerListArray?[indexPath.row].isFav ?? designerListArray?[indexPath.row].isFav ?? false) ? "add" : "del"
            HomeManager.apiEditFavProviderList(pId: providerListArray?[indexPath.row].pId, dId: designerListArray?[indexPath.row].dId, act: act, success: { [unowned self](model) in
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
                self.refreshControl.endRefreshing()
            }, failure: { (error) in
                self.refreshControl.endRefreshing()
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiGetFavProviderListWithShowLoading(_ isShowLoading: Bool) {
        if SystemManager.isNetworkReachable() {
            if isShowLoading { self.showLoading() }
            
            HomeManager.apiGetFavProviderList(page: self.currentPage, pMax: 30, success: { [unowned self] (model) in
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
                    if let designerList = model?.data?.designerList {
                        if self.currentPage == 1 {
                            self.designerListArray = designerList
                        } else {
                            self.designerListArray?.append(contentsOf: designerList)
                        }
                    } else {
                        self.designerListArray = nil
                    }
                    self.collectionView.reloadData(providerListArray: self.providerListArray, designerListArray: self.designerListArray)
                    self.removeMaskView()
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
                self.refreshControl.endRefreshing()
            },failure: { [unowned self] (error) in
                self.refreshControl.endRefreshing()
                self.removeMaskView()
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension MyHomeWallViewController: ProviderInfoCollectionViewDelegate {
    
    func heartButtonClickAt(indexPath: IndexPath) {
        apiEditFavProviderListWith(indexPath: indexPath)
    }
    
    func findSiteButtonPress() {
        SystemManager.changeTabBarSelectIndex(index: 0)
    }
    
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
    
    func collectionWillDisplayCellAt(indexPath: IndexPath) {
        let compareCount = providerListArray?.count ?? designerListArray?.count ?? 0
        if indexPath.item == compareCount - 3 && currentPage < totalPage {
            currentPage += 1
            apiGetFavProviderListWithShowLoading(false)
        }
    }
}
