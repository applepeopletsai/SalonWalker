//
//  ServicePriceViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit


class ServicePriceViewController: BaseViewController {

    @IBOutlet private weak var tableView: UITableView!

    private var svcItemsInfoModel: SvcItemsInfoModel?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addObser()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Method
    func callAPI() {
        if svcItemsInfoModel?.svcCategory == nil {
            apiGetSvcItems()
        }
    }
    
    private func addObser() {
        NotificationCenter.default.addObserver(self, selector: #selector(reflashVC), name: NSNotification.Name(rawValue: kReFlashServicePriceVC), object: nil)
    }
    
    @objc private func reflashVC() {
        apiGetSvcItems()
    }
    
    // MARK: API
    private func apiGetSvcItems() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            DesignerServiceManager.apiGetSvcItems(success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.svcItemsInfoModel = model?.data
                    self.tableView.reloadData()
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
}

extension ServicePriceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return svcItemsInfoModel?.svcCategory?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ServicePriceTableViewCell.self), for: indexPath) as! ServicePriceTableViewCell
        if let model = svcItemsInfoModel?.svcCategory?[indexPath.row] {
            cell.setupCellWith(categoryModel: model)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: FixPriceViewController.self)) as! FixPriceViewController
        vc.setupVCWith(svcItemsInfoModel: svcItemsInfoModel, editIndex: indexPath.row)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

