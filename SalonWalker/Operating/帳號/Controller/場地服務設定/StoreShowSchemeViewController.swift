//
//  StoreShowSchemeViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/15.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class StoreShowSchemeViewController: BaseViewController {
    
    @IBOutlet weak var schemeLabel: IBInspectableLabel!
    @IBOutlet weak var schemeSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
   
    private var schemeType: PaySchemeType = .hour
    private var model: PlaceSvcPricesModel?
    private var workTimeArray = [WorkTimeModel]()

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: Method
    func setupVCWith(model: PlaceSvcPricesModel, type: PaySchemeType) {
        self.model = model
        self.schemeType = type
        
        if type == .hour {
            if let array = model.svcHours?.svcHoursPrices {
                self.workTimeArray = ProviderServiceManager.getWorkTimeModel(array)
            }
        } else if type == .times {
            if let array = model.svcTimes?.svcTimesPrices {
                self.workTimeArray = ProviderServiceManager.getWorkTimeModel(array)
            }
        }
    }
    
    private func setupUI() {
        if let model = model {
            if schemeType == .hour {
                self.schemeLabel.text = LocalizedString("Lang_PS_002")
                self.schemeSwitch.isOn = (model.svcHours?.open ?? false)
            } else if schemeType == .times {
                self.schemeLabel.text = LocalizedString("Lang_PS_003")
                self.schemeSwitch.isOn = (model.svcTimes?.open ?? false)
            }
        }
    }
    
    private func checkField() -> String? {
        for i in 0..<workTimeArray.count {
            let model = workTimeArray[i]
            if (model.weekIndex != nil && model.price == nil) ||
                (model.weekIndex == nil && model.price != nil) {
                return "\(LocalizedString("Lang_AC_057"))(\(i + 1))\(LocalizedString("Lang_DD_025"))"
            }
        }
        return nil
    }
    
    // MARK: Event Handler
    @IBAction func switchClick(_ sender: UISwitch) {
        if schemeType == .hour {
            model?.svcHours?.open = sender.isOn
        } else if schemeType == .times {
            model?.svcTimes?.open = sender.isOn
        }
    }
    
    @IBAction func saveButtonClick(_ sender: UIButton) {
        if let text = checkField() {
            SystemManager.showWarningBanner(title: text, body: "")
        } else {
            apiSetPlaceSvcPrices()
        }
    }
    
    //MARK: API
    private func apiSetPlaceSvcPrices() {
        guard var model = model else { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            var array = [HoursAndTimesPricesModel]()
            for model in workTimeArray {
                if let index = model.weekIndex, let price = model.price {
                    for week in index {
                        array.append(HoursAndTimesPricesModel(weekDay: week, prices: price))
                    }
                }
            }
            
            if schemeType == .hour {
                if model.svcHours?.svcHoursPrices == nil {
                    model.svcHours = SvcHoursAndTimesPriceModel(open: schemeSwitch.isOn, svcHoursPrices: array, svcTimesPrices: nil)
                } else {
                    model.svcHours?.svcHoursPrices = array
                }
            } else if schemeType == .times {
                if model.svcTimes?.svcTimesPrices == nil {
                    model.svcTimes = SvcHoursAndTimesPriceModel(open: schemeSwitch.isOn, svcHoursPrices: nil, svcTimesPrices: array)
                } else {
                    model.svcTimes?.svcTimesPrices = array
                }
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

extension StoreShowSchemeViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workTimeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreShowSchemeTableViewCell", for: indexPath) as! StoreShowSchemeTableViewCell
        cell.setupCellWith(model: workTimeArray[indexPath.row], type: schemeType, indexPath: indexPath, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
        /* 已詢問 Catherine 增加欄位上限暫定為 30 個 , By Scott 2018/06/21 */
        if workTimeArray.count < 30 {
            let imageView = UIImageView(frame: CGRect(x: screenWidth - 30 , y: 15, width: 13, height: 13))
            imageView.image = UIImage(named: "ic_items_add")
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            let addButton = UIButton(frame: CGRect(x: screenWidth - 45, y: 0, width: 45, height: 50))
            addButton.addTarget(self, action: #selector(addButtonClick(_:)), for: .touchUpInside)
            footerView.addSubview(imageView)
            footerView.addSubview(addButton)
        }
        return footerView
    }
    
    @objc func addButtonClick(_ sender: UIButton!) {
        self.workTimeArray.append(WorkTimeModel(weekIndex: nil, from: nil, end: nil, price: nil))
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
            self.tableView.scrollToRow(at: IndexPath(row: self.workTimeArray.count - 1, section: 0), at: .none, animated: true)
        })
    }
}

extension StoreShowSchemeViewController: StoreShowSchemeTableViewCellDelegate {
    func textFieldEditingChange(indexPath: IndexPath, price: Int?) {
        self.workTimeArray[indexPath.row].price = price
    }
    
    func didSelectWeek(with selectIndexArray: [Int], at indexPath: IndexPath) {
        self.workTimeArray[indexPath.row].weekIndex = (selectIndexArray.count > 0) ? selectIndexArray : nil
    }
    
    func deleteButtonPressAt(indexPath: IndexPath) {
        let model = workTimeArray[indexPath.row]
        if model.weekIndex != nil || model.price != nil {
            PresentationTool.showTwoButtonAlertWith(image: UIImage(named: "img_time_delete"), message: LocalizedString("Lang_AC_049"), leftButtonTitle: LocalizedString("Lang_GE_060"), leftButtonAction: nil, rightButtonTitle: LocalizedString("Lang_AC_048"), rightButtonAction: {
                self.workTimeArray.remove(at: indexPath.row)
                self.tableView.reloadData()
            })
        } else {
            self.workTimeArray.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
}
