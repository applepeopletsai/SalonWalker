//
//  ForgotPasswordViewController.swift
//  SalonWalker
//
//  Created by skywind on 2018/3/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: BaseViewController {
    
    @IBOutlet private weak var colorView: UIView!
    @IBOutlet private weak var telField: IBInspectableTextField!
    @IBOutlet private weak var verifyButton: IBInspectableButton!
    @IBOutlet private weak var phoneCodeButton: IBInspectableButton!
    
    private var phoneCodeArray: [PhoneCodeModel] = []
    private var phoneCode = "886"
    private var selectedPhoneCodeIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPhoneCodeArray()
        setupColor()
        setupButton()
        setupTextField()
    }
    
    private func setupPhoneCodeArray() {
        if let array = SystemManager.getPhoneCodeModel() {
            phoneCodeArray = array
            getSelectPhoneCodeIndex()
        }
    }
    
    private func setupTextField() {
        telField.addTarget(self, action: #selector(textDidChange(_:)), for: .allEditingEvents)
    }
    
    private func setupButton() {
        phoneCodeButton.setTitle("(+\(phoneCode))", for: .normal)
        verifyButton.backgroundColor = color_AAAAAA
    }
    
    private func setupColor() {
        if SystemManager.getAppIdentity() == .SalonWalker {
            colorView.backgroundColor = color_E1FFF4
        } else {
            colorView.backgroundColor = color_7A57FA
        }
    }

    private func showPhoneCodePicker() {
        var array: [String] = []
        for model in self.phoneCodeArray {
            array.append(model.internationalPrefix + model.country)
        }
        
        PresentationTool.showPickerWith(itemArray: array, selectedIndex: selectedPhoneCodeIndex, cancelAction: nil, confirmAction: { [unowned self] (item, index) in
            self.phoneCodeButton.setTitle("(+\(self.phoneCodeArray[index].internationalPrefix))", for: .normal)
            self.phoneCode = self.phoneCodeArray[index].internationalPrefix
            self.selectedPhoneCodeIndex = index
        })
    }
    
    private func getSelectPhoneCodeIndex() {
        for i in 0..<self.phoneCodeArray.count {
            let model = self.phoneCodeArray[i]
            
            if self.phoneCode == model.internationalPrefix {
                self.selectedPhoneCodeIndex = i
            }
        }
    }
    
    private func goToVerifyPasswordVCWithVerifyCode() {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "VerifyPasswordViewController") as! VerifyPasswordViewController
        vc.setupVCWith(phoneCode: phoneCode, phone: telField.text!)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        if let verify = textField.text {
            self.verifyButton.backgroundColor = (verify.count > 0) ? color_1A1C69 : color_AAAAAA
            self.verifyButton.isUserInteractionEnabled = (verify.count > 0) ? true : false
        }
    }
    
    // MARK: Event Handler
    @IBAction func sendVerifyOnClick(_ sender: Any) {
        if !telField.text!.validateCellphone() {
            SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_LI_031"), alertMessage: LocalizedString("Lang_LI_032"), buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
            return
        }
        apiSendVerify()
    }
    
    @IBAction func phoneCodeButtonPress(_ sender: IBInspectableButton) {
        if phoneCodeArray.count == 0 {
            apiGetPhoneCode { [unowned self] in
                self.showPhoneCodePicker()
            }
            return
        }
        showPhoneCodePicker()
    }
    
    //  MARK: API
    private func apiGetPhoneCode(success: actionClosure?) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            SystemManager.apiGetPhoneCode(success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    if let phoneCodeModel = model?.data {
                        SystemManager.savePhoencodeModel(phoneCodeModel)
                        self.phoneCodeArray = phoneCodeModel
                        self.getSelectPhoneCodeIndex()
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

    private func apiSendVerify() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            if SystemManager.getAppIdentity() == .SalonWalker {
                MemberManager.apiSetVerify(confirmType: "2", internationalPrefix: phoneCode, phone: telField.text!, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        if let mId = model?.data?.mId {
                            UserManager.sharedInstance.mId = mId
                            self.goToVerifyPasswordVCWithVerifyCode()
                        }
                        self.hideLoading()
                    } else {
                        self.endLoadingWith(model: model)
                    }
                    }, failure: { (error) in
                        SystemManager.showErrorAlert(error: error)
                })
            } else {
                OperatingManager.apiSetVerify(confirmType: "2", internationalPrefix: phoneCode, phone: telField.text!, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        if let ouId = model?.data?.ouId {
                            UserManager.sharedInstance.ouId = ouId
                            self.goToVerifyPasswordVCWithVerifyCode()
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
}
