//
//  FullSiteRankingViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class FullSiteRankingViewController: BaseViewController {
    
    @IBOutlet private weak var tableView: DesignerInfoTableView!
    @IBOutlet private weak var filterView: FilterView!
    @IBOutlet private weak var nonDataView: UIView!
    
    private var filterModel: CityCodeModel.CityModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
        setupFilterView()
        setupTableView()
    }
    
    // MARK: Method
    func callAPI() {
        tableView.callAPI()
    }
    
    func checkRecentSearchData() {
        filterView?.checkRecentSearchData()
    }
    
    private func setupFilterView() {
        filterView.setupFilterViewWith(targetVC: self, delegate: self)
    }
    
    private func setupTableView() {
        tableView.setupTableViewWith(targetViewController: self, tableViewType: .FullSiteRanking, delegate: self)
    }
    
    private func searchDesigner() {
        tableView.getTopDesignerWith(filterModel: filterModel)
    }
    
    // MARK: API
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
}

extension FullSiteRankingViewController: DesignerInfoTableViewDelegate {
 
    func didUpdateDesignerList(designerListCount: Int) {
        self.nonDataView.isHidden = (designerListCount == 0) ? false : true
    }
}

extension FullSiteRankingViewController: FilterViewDelegate {
    
    func didPressFinishButton(_ model: CityCodeModel.CityModel?) {
        self.filterModel = model
        self.searchDesigner()
    }
    
    func didPressSearchButton(_ model: CityCodeModel.CityModel?) {
        self.filterModel = model
        self.searchDesigner()
    }
    
    func didSelectRecentSearch(_ model: CityCodeModel.CityModel?) {
        self.filterModel = model
        self.searchDesigner()
    }
}
