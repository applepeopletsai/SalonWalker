//
//  StorePaySchemeViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/3.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

let kRecallApiGetPlaceSvcPrices = "RecallApiGetPlaceSvcPrices"

class StorePaySchemeViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var placeSvcPricesModel: PlaceSvcPricesModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        addObser()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func callAPI() {
        if placeSvcPricesModel == nil {
            apiGetPlaceSvcPrices()
        }
    }
    
    private func addObser() {
        NotificationCenter.default.addObserver(self, selector: #selector(recallAPI), name: NSNotification.Name(rawValue: kRecallApiGetPlaceSvcPrices), object: nil)
    }
    
    @objc private func recallAPI() {
        apiGetPlaceSvcPrices()
    }
    
    // MARK: API
    private func apiGetPlaceSvcPrices() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            ProviderServiceManager.apiGetPlaceSvcPrices(success: { [unowned self](model) in
                if model?.syscode == 200 {
                    self.placeSvcPricesModel = model?.data
                    self.tableView.reloadData()
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
            },failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension StorePaySchemeViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StorePaySchemeTableViewCell", for: indexPath) as! StorePaySchemeTableViewCell
        
        var text = ""
        var open = false
        switch indexPath.row {
        case 0:
            text = LocalizedString("Lang_PS_002")
            open = (placeSvcPricesModel?.svcHours?.open) ?? false
            break
        case 1:
            text = LocalizedString("Lang_PS_003")
            open = (placeSvcPricesModel?.svcTimes?.open) ?? false
            break
        case 2:
            text = LocalizedString("Lang_PS_004")
            open = (placeSvcPricesModel?.svcLongLease?.open) ?? false
            break
        default:
            break
        }
        
        cell.setupCellWith(title: text, open: open)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var vc = UIViewController()
        switch indexPath.row {
        case 0, 1:
            vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: "StoreShowSchemeViewController") as! StoreShowSchemeViewController
            if let model = placeSvcPricesModel {
                (vc as! StoreShowSchemeViewController).setupVCWith(model: model, type: (indexPath.row == 0) ? .hour : .times)
            }
            break
        case 2:
            vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: "StoreShowRentSchemeViewController") as! StoreShowRentSchemeViewController
            if let model = placeSvcPricesModel {
                (vc as! StoreShowRentSchemeViewController).setupVCWithModel(model)
            }
            break
        default:break
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

