//
//  DeviceTableView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

let deviceNormalCellHeight: CGFloat = 40.0
let deviceTextFieldCellHeight: CGFloat = 120.0

protocol DeviceTableViewDelegate: class {
    func updateDeviceData(with deviceArray: [EquipmentItemModel.Equipment])
    func getDeviceSuccess(with deviceArray: [EquipmentItemModel.Equipment])
}

class DeviceTableView: UITableView {

    private var deviceArray = [EquipmentItemModel.Equipment]()
    
    private weak var targetVC: BaseViewController?
    private weak var deviceTableViewDelegate: DeviceTableViewDelegate?
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = self
        self.delegate = self
        registerCell()
    }
    
    // MARK: Method
    func setupTableViewWith(targetViewController: BaseViewController, delegate: DeviceTableViewDelegate) {
        self.targetVC = targetViewController
        self.deviceTableViewDelegate = delegate
        self.apiGetEquipment()
    }
    
    func reloadDataWithDeviceArray(_ deviceArray: [EquipmentItemModel.Equipment]) {
        self.deviceArray = deviceArray
        self.reloadData()
    }
    
    private func registerCell() {
        self.register(UINib(nibName: "DeviceCell", bundle: nil), forCellReuseIdentifier: String(describing: DeviceCell.self))
        self.register(UINib(nibName: "DeviceTextViewCell", bundle: nil), forCellReuseIdentifier: String(describing: DeviceTextViewCell.self))
    }

    // MARK: API
    private func apiGetEquipment() {
        self.targetVC?.showLoading()
        
        OperatingManager.apiGetEquipment(success: { [unowned self] (model) in
            if model?.syscode == 200 {
                if let devices = model?.data?.equipment {
                    self.deviceArray = devices
                    self.reloadData()
                }
                self.targetVC?.hideLoading()
            } else {
                self.targetVC?.endLoadingWith(model: model)
            }
            self.deviceTableViewDelegate?.getDeviceSuccess(with: self.deviceArray)
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
        })
    }
}

extension DeviceTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = deviceArray[indexPath.row]
        
        if model.permitCharacterization {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DeviceTextViewCell.self), for: indexPath) as! DeviceTextViewCell
            cell.setupCellWith(model: model, row: indexPath.row, target: self)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DeviceCell.self), for: indexPath) as! DeviceCell
            cell.setupCellWith(model: model, row: indexPath.row, target: self)
            return cell
        }
    }
}

extension DeviceTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if deviceArray[indexPath.row].permitCharacterization {
            return deviceTextFieldCellHeight
        } else {
            return deviceNormalCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        deviceArray[indexPath.row].selected = !deviceArray[indexPath.row].selected
        reloadData()
        
        if deviceArray[indexPath.row].selected {
            if let cell = tableView.cellForRow(at: indexPath) as? DeviceCell {
                if deviceArray[indexPath.row].count == 0 {
                    cell.textFieldBecomeFirstResponder()
                }
            } else if let cell = tableView.cellForRow(at: indexPath) as? DeviceTextViewCell {
                if deviceArray[indexPath.row].content.count == 0 {
                    cell.textViewBecomeFirstResponder()
                }
            }
        }
        deviceTableViewDelegate?.updateDeviceData(with: self.deviceArray)
    }
}

extension DeviceTableView: DeviceCellDelegate {
    
    func textFieldDidEndEditing(text: String?, row: Int) {
        if let text = text, let count = Int(text) {
            deviceArray[row].count = count
        } else {
            deviceArray[row].count = 0
        }
        deviceTableViewDelegate?.updateDeviceData(with: deviceArray)
    }
}

extension DeviceTableView: DeviceTextViewCellDelegate {
    
    func textViewDidEndEditing(text: String?, row: Int) {
        deviceArray[row].content = text ?? ""
        deviceTableViewDelegate?.updateDeviceData(with: deviceArray)
    }
}



