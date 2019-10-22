//
//  GetFundModeViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/25.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol GetFundModeViewControllerDelegate: class {
    func didEditBankData()
}

class GetFundModeViewController: BaseViewController {

    @IBOutlet weak var saveButton: IBInspectableButton!
    @IBOutlet weak var bankCodeLabel: UILabel!
    @IBOutlet weak var branchTextField: UITextField!
    @IBOutlet weak var bankNumTextField: UITextField!
    
    private weak var delegate: GetFundModeViewControllerDelegate?
    private var bankInfoModel: BankInfoModel?
    private var bankArray: [BankModel] = []
    private var selectBank: BankModel?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    // MARK: Method
    override func networkDidRecover() {
        callAPI()
    }
    
    func setupVCWith(model: BankInfoModel, delegate: GetFundModeViewControllerDelegate) {
        self.bankInfoModel = model
        self.delegate = delegate
    }
    
    func setupVC(_ bankInfoModel: BankInfoModel) {
        self.bankInfoModel = bankInfoModel
    }
    
    private func callAPI() {
        if bankArray.count == 0 {
            apiGetBank()
        }
    }
    
    private func setupUI() {
        if let model = self.bankInfoModel {
            self.branchTextField.text = model.bankBranch
            self.bankNumTextField.text = model.bankNum
            
            if model.bankName.count > 0 {
                self.bankCodeLabel.text = String(model.bankName + model.bankCode)
                self.bankCodeLabel.textColor = .black
                self.selectBank = BankModel(bankCode: model.bankCode, bankName: model.bankName)
            }
        }
    }
    
    private func showBankPickerView() {
        let array = self.bankArray.map({ $0.bankName + $0.bankCode })
        let selectIndex = array.index(of: self.bankCodeLabel.text ?? "") ?? 0
        PresentationTool.showPickerWith(itemArray: array, selectedIndex: selectIndex, cancelAction: nil, confirmAction: { [unowned self] (item, index) in
            self.bankCodeLabel.text = item
            self.bankCodeLabel.textColor = .black
            self.selectBank = BankModel(bankCode: self.bankArray[index].bankCode, bankName: self.bankArray[index].bankName)
            self.changeSaveButtonEnableStatus(bankBranchText: self.branchTextField.text, bankNumText: self.bankNumTextField.text)
        })
    }
    
    private func changeSaveButtonEnableStatus(bankBranchText: String?, bankNumText: String?) {
        if let model = bankInfoModel {
            var enable = false
            
            if let bankCode = selectBank?.bankCode, let bankNum = bankNumText, bankNum.count > 0  {
                if bankCode != model.bankCode ||
                    bankNum != model.bankNum {
                    enable = true
                }
                if let bankBranch = bankBranchText, bankBranch != model.bankBranch {
                    enable = true
                }
            }
            saveButton.isEnabled = enable
        }
    }
    
    // MARK: Event Handler
    @IBAction func bankCodeButtonClick(_ sender: UIButton) {
        if self.bankArray.count == 0 {
            self.apiGetBank(showBankPickerView)
        } else {
            showBankPickerView()
        }
    }
    
    @IBAction func saveButtonClick(_ sender: UIButton) {
        apiSetOperatingTxnSetting()
    }
    
    // MARK: API
    private func apiSetOperatingTxnSetting() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            let array = self.bankArray.map({ $0.bankName + $0.bankCode })
            let selectIndex = array.index(of: self.bankCodeLabel.text ?? "") ?? 0
            let bank = self.bankArray[selectIndex]
            
            TransactionSettingManager.apiSetOperatingTxnSetting(bankCode: bank.bankCode, bankBranch: branchTextField.text ?? "", bankNum: bankNumTextField.text!, success: { (model) in
                if model?.syscode == 200 {
                    SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_GE_021"), body: "")
                    self.delegate?.didEditBankData()
                    self.hideLoading()
                    self.navigationController?.popViewController(animated: true)
                }else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiGetBank(_ success: actionClosure? = nil) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            TransactionSettingManager.apiGetBank(success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    if let bankArray = model?.data?.bank {
                        self.bankArray = bankArray
                        success?()
                    }
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension GetFundModeViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let totalString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if textField == branchTextField {
            self.changeSaveButtonEnableStatus(bankBranchText: totalString, bankNumText: bankNumTextField.text)
        } else {
            self.changeSaveButtonEnableStatus(bankBranchText: branchTextField.text, bankNumText: totalString)
        }
        return true
    }
}
