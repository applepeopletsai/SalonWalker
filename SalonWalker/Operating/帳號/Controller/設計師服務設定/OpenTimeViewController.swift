//
//  OpenTimeViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class OpenTimeViewController: BaseViewController {
    @IBOutlet weak var tableView: OpenTimeTableView!
    
    private var workTimeArray: [WorkTimeModel] = []
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.setupTableViewWith(workTimeArray: [], cellType: .designerOpenTime, delegate: self)
    }
    
    // MARK: Method
    func naviRightButtonClick() {
        if let text = checkWorkTimeField() {
            SystemManager.showWarningBanner(title: text, body: "")
        } else {
            apiSetOpenHours()
        }
    }
    
    func callAPI() {
        if workTimeArray.count == 0 {
            apiGetOpenHours()
        }
    }
    
    private func checkWorkTimeField() -> String? {
        for i in 0..<workTimeArray.count {
            let model = workTimeArray[i]
            if (model.weekIndex != nil && (model.from == nil || model.end == nil)) ||
                (model.from != nil && (model.weekIndex == nil || model.end == nil)) ||
                (model.end != nil && (model.weekIndex == nil || model.from == nil)) {
                return "\(LocalizedString("Lang_DD_004"))(\(i+1))\(LocalizedString("Lang_DD_025"))"
            }
        }
        return nil
    }
    
    // MARK: API
    private func apiGetOpenHours() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            ServiceHoursManager.apiGetOpenHours(success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    if let workTimeArray = model?.data {
                        self.workTimeArray = workTimeArray
                    }
                    self.tableView.reloadDataWith(workTimeArray: self.workTimeArray)
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiSetOpenHours() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            ServiceHoursManager.apiSetOpenHours(openHour: workTimeArray, success: { (model) in
                if model?.syscode == 200 {
                    SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_GE_021"), body: "")
                    self.hideLoading()
                    self.apiDesignerEditInfo()
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiDesignerEditInfo() {
        if SystemManager.isNetworkReachable(showBanner: false) {
            PushManager.apiDesignerEditInfo(success: nil, failure: nil)
        }
    }
}

extension OpenTimeViewController: OpenTimeTableViewDelegate {
    func addWorkTime() {
        self.workTimeArray.append(WorkTimeModel(weekIndex: nil, from: nil, end: nil, price: nil))
    }
    
    func didChangeWorkTime(with model: WorkTimeModel, at indexPath: IndexPath) {
        self.workTimeArray[indexPath.row] = model
    }
    
    func deleteWorkTimeAt(indexPath: IndexPath) {
        self.workTimeArray.remove(at: indexPath.row)
    }
}
