//
//  BargainSettingViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/25.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class BargainSettingViewController: BaseViewController {
    
    @IBOutlet weak var getFuncModeLabel: IBInspectableLabel!
    
    private var bankInfoModel: BankInfoModel?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    // MARK: Method
    override func networkDidRecover() {
        callAPI()
    }
    
    private func setupUI() {
        self.getFuncModeLabel.text = LocalizedString("Lang_AC_013")
        if let model = bankInfoModel {
            if model.bankName.count > 0 &&
                model.bankCode.count > 0 &&
                model.bankNum.count > 0 {
                self.getFuncModeLabel.text = "\(model.bankName)\(model.bankCode)/********\(model.bankNum.suffix(4))"
            }
        }
    }
    
    private func callAPI() {
        if bankInfoModel == nil {
            apiGetOperatingTxnSetting()
        }
    }
    
    // MARK: Event Handler
    @IBAction func addGetFundButtonClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: "GetFundModeViewController") as! GetFundModeViewController
        
        if let bankInfoModel = self.bankInfoModel {
            vc.setupVCWith(model: bankInfoModel, delegate: self)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func readTransactionTermButtonClick(_ sender: UIButton) {
        SystemManager.openTransactionTerms()
    }
    
    // MARK: API
    private func apiGetOperatingTxnSetting() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            TransactionSettingManager.apiGetOperatingTxnSetting(success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.bankInfoModel = model?.data
                    self.setupUI()
                    self.hideLoading()
                    self.removeMaskView()
                } else {
                    self.endLoadingWith(model: model)
                }
            },failure: { [unowned self] (error) in
                self.removeMaskView()
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension BargainSettingViewController: GetFundModeViewControllerDelegate {
    func didEditBankData() {
        apiGetOperatingTxnSetting()
    }
}
