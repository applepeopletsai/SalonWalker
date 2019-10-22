//
//  ChangePhoneNumberViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/19.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ChangePhoneNumberViewController: BaseViewController {
    
    @IBOutlet private weak var phoneCodeLabel: UILabel!
    @IBOutlet private weak var phoneNumberTextField: IBInspectableTextField!
    
    private var phoneCodeArray: [PhoneCodeModel] = []
    private var phoneCode = ""
    private var phone = ""
    private var selectedPhoneCodeIndex = 0
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPhoneCodeArray()
    }
    
    // Method
    func setupVCWith(phoneCode: String, phone: String) {
        self.phoneCode = phoneCode
        self.phone = phone
    }
    
    func setupUI() {
        self.phoneCodeLabel.text = "+\(phoneCode)"
        self.phoneNumberTextField.text = phone
    }
    
    private func setupPhoneCodeArray() {
        if let array = SystemManager.getPhoneCodeModel() {
            phoneCodeArray = array
            getSelectPhoneCodeIndex()
        }
    }
    
    private func getSelectPhoneCodeIndex() {
        for i in 0..<self.phoneCodeArray.count {
            let model = self.phoneCodeArray[i]
            
            if self.phoneCode == model.internationalPrefix {
                self.selectedPhoneCodeIndex = i
            }
        }
    }
    
    private func showPhoneCodePicker() {
        var array: [String] = []
        for model in self.phoneCodeArray {
            array.append(model.internationalPrefix + model.country)
        }
        PresentationTool.showPickerWith(itemArray: array, selectedIndex: selectedPhoneCodeIndex, cancelAction: nil, confirmAction: { [unowned self] (item, index) in
            self.phoneCodeLabel.text = "+\(self.phoneCodeArray[index].internationalPrefix)"
            self.phoneCode = self.phoneCodeArray[index].internationalPrefix
            self.selectedPhoneCodeIndex = index
        })
    }
    
    private func gotoEnterVerifyVC() {
        PresentationTool.showNoButtonAlertWith(image: UIImage(named: "img_sentpw"), message: LocalizedString("Lang_ST_023"), completion: { [unowned self] in
            let vc = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "EnterVerifyCodeViewController") as! EnterVerifyCodeViewController
            vc.setupVCWith(internationalPrefix: self.phoneCode, phoneNum: self.phoneNumberTextField.text!)
            self.present(vc, animated: true, completion: nil)
        })
    }
    
    // MARK: EventHandler
    @IBAction func dismissButtonClick(_ sender: UIButton) {
       dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonClick(_ sender: UIButton) {
        if phoneNumberTextField.text?.count == 0 {
            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_LI_017"), body: "")
            return
        }
        
        if !phoneNumberTextField.text!.validateCellphone() {
            SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_LI_031"), alertMessage: LocalizedString("Lang_LI_032"), buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
            return
        }
        
        apiSetChgPhoneVerify()
    }
    
    @IBAction func phoneCodeButtonClick(_ sender: UIButton) {
        if self.phoneCodeArray.count == 0 {
            apiGetPhoneCode { [unowned self] in
                self.showPhoneCodePicker()
            }
            return
        }
        
        showPhoneCodePicker()
    }
    
    // MARK: API
    private func apiGetPhoneCode(success: actionClosure?) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            SystemManager.apiGetPhoneCode(success: { (model) in
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
    
    private func apiSetChgPhoneVerify() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            if UserManager.sharedInstance.userIdentity == .consumer {
                MemberManager.apiSetChgPhoneVerify(internationalPrefix: phoneCode, phone: phoneNumberTextField.text!, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        self.gotoEnterVerifyVC()
                        self.hideLoading()
                    } else {
                        self.endLoadingWith(model: model)
                    }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
                })
            } else {
                OperatingManager.apiSetChgPhoneVerify(internationalPrefix: phoneCode, phone: phoneNumberTextField.text!, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        self.gotoEnterVerifyVC()
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

extension ChangePhoneNumberViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            return (text.count + string.count - range.length) <= 10
        }
        return false
    }
}
