//
//  StoreShowRentSchemeViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/16.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class StoreShowRentSchemeViewController: BaseViewController {

    @IBOutlet weak var schemeSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    
    private var model: PlaceSvcPricesModel?
    private var longLeasePricesArray: [LongLeasePricesModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: Method
    func setupVCWithModel(_ model: PlaceSvcPricesModel) {
        self.model = model
        if let array = model.svcLongLease?.svcLongLeasePrices {
            self.longLeasePricesArray = array
        }
    }
    
    func setupUI() {
        if let model = model {
            self.schemeSwitch.isOn = model.svcLongLease?.open ?? false
        }
    }
    
    private func checkField() -> String? {
        for i in 0..<longLeasePricesArray.count {
            let model = longLeasePricesArray[i]
            if (model.startDay != nil && (model.endDay == nil || model.prices == nil)) ||
                (model.endDay != nil && (model.startDay == nil || model.prices == nil)) || (model.prices != nil && (model.startDay == nil || model.endDay == nil)){
                return "\(LocalizedString("Lang_AC_057"))(\(i + 1))\(LocalizedString("Lang_DD_025"))"
            }
        }
        
        return nil
    }
    
    //MARK: Event Handler
    @IBAction func saveButtonClick(_ sender: UIButton) {
        if let text = checkField() {
            SystemManager.showWarningBanner(title: text, body: "")
        } else {
            apiSetPlaceSvcPrices()
        }
    }
    
    @IBAction func schemeSwitchClick(_ sender: UISwitch) {
        model?.svcLongLease?.open = sender.isOn
    }
    
    // MARK: API
    private func apiSetPlaceSvcPrices() {
        guard var model = model else { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            if model.svcLongLease?.svcLongLeasePrices == nil {
                model.svcLongLease = SvcLongLeasePricesModel(open: model.svcLongLease?.open, svcLongLeasePrices: longLeasePricesArray)
            } else {
                model.svcLongLease?.svcLongLeasePrices = longLeasePricesArray
            }
            
            ProviderServiceManager.apiSetPlaceSvcPrices(model: model, success: { (model) in
                if model?.syscode == 200 {
                    SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_GE_021"), body: "")
                    self.hideLoading()
                    self.navigationController?.popViewController(animated: true, completion: {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRecallApiGetPlaceSvcPrices), object: nil)
                    })
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension StoreShowRentSchemeViewController: UITableViewDelegate ,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return longLeasePricesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreShowRentSchemeTableViewCell", for: indexPath) as! StoreShowRentSchemeTableViewCell
        cell.setupCellWith(model: longLeasePricesArray[indexPath.row], indexPath: indexPath, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if longLeasePricesArray.count < 30 {
            return 50
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if longLeasePricesArray.count < 30 {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
            let imageView = UIImageView(frame: CGRect(x: screenWidth - 30 , y: 15, width: 13, height: 13))
            imageView.image = UIImage(named: "ic_items_add")
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            let addButton = UIButton(frame: CGRect(x: screenWidth - 45, y: 0, width: 45, height: 50))
            addButton.addTarget(self, action: #selector(addButtonClick(_:)), for: .touchUpInside)
            footerView.addSubview(imageView)
            footerView.addSubview(addButton)
            return footerView
        }
        return nil
    }
    
    @objc func addButtonClick(_ sender: UIButton!) {
        self.longLeasePricesArray.append(LongLeasePricesModel(startDay: nil, endDay: nil, prices: nil))
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
            self.tableView.scrollToRow(at: IndexPath(row: self.longLeasePricesArray.count - 1, section: 0), at: .none, animated: true)
        })
    }
}

extension StoreShowRentSchemeViewController: StoreShowRentSchemeTableViewCellDelegate {
    func deleteButtonClickAt(_ indexPath: IndexPath) {
        let model_ = longLeasePricesArray[indexPath.row]
        if model_.startDay != nil ||
            model_.endDay != nil ||
            model_.prices != nil {
            PresentationTool.showTwoButtonAlertWith(image: UIImage(named: "img_time_delete"), message: LocalizedString("Lang_AC_049"), leftButtonTitle: LocalizedString("Lang_GE_060"), leftButtonAction: nil, rightButtonTitle: LocalizedString("Lang_AC_048"), rightButtonAction: {
                self.longLeasePricesArray.remove(at: indexPath.row)
                self.tableView.reloadData()
            })
        } else {
            self.longLeasePricesArray.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    func didSelectStartDate(at indexPath: IndexPath, with startDate: String) {
        self.longLeasePricesArray[indexPath.row].startDay = startDate
    }
    
    func didSelectEndDate(at indexPath: IndexPath, with endDate: String) {
        self.longLeasePricesArray[indexPath.row].endDay = endDate
    }
    
    func textFieldEditingChange(at indexPath: IndexPath, with price: Int?) {
        self.longLeasePricesArray[indexPath.row].prices = price
    }
}

