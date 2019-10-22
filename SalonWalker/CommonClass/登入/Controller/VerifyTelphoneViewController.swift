//
//  VerifyTelphoneViewController.swift
//  SalonWalker
//
//  Created by skywind on 2018/3/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class VerifyTelphoneViewController: BaseViewController {

    @IBOutlet private weak var textField: IBInspectableTextField!
    @IBOutlet private weak var phoneCodeButton: IBInspectableButton!
    @IBOutlet private weak var sendVerifyButton: IBInspectableButton!
    @IBOutlet private weak var agreeTermsLabel: UILabel!
    
    private var phoneCodeArray: [PhoneCodeModel] = []
    private var phoneCode = "886"
    private var selectedPhoneCodeIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPhoneCodeArray()
        setupButton()
        setupTextField()
        setupLabel()
    }
    
    private func setupPhoneCodeArray() {
        if let array = SystemManager.getPhoneCodeModel() {
            phoneCodeArray = array
            getSelectPhoneCodeIndex()
        }
    }
    
    private func setupButton() {
        phoneCodeButton.setTitle("(+\(phoneCode))", for: .normal)
        sendVerifyButton.backgroundColor = color_AAAAAA
    }
    
    private func setupTextField() {
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: .allEditingEvents)
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
    
    private func goToEnterVerifyVCWithVerifyCode() {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "EnterVerifyViewController") as! EnterVerifyViewController
        vc.setupVCWith(phoneCode: phoneCode, phone: textField.text!)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupLabel() {
        let text = LocalizedString("Lang_LI_021")
        let attributedString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: LocalizedString("Lang_RD_010"))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color_1A1C69, range: range)
        self.agreeTermsLabel.attributedText = attributedString
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        self.agreeTermsLabel.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func tap(_ gesture: UITapGestureRecognizer) {
        if gesture.didTapSpecificText(text: LocalizedString("Lang_RD_010"), onLabel: self.agreeTermsLabel) {
            SystemManager.openServiceTerms()
        }
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        if let phone = textField.text {
            self.sendVerifyButton.backgroundColor = (phone.count > 0) ? color_1A1C69 : color_AAAAAA
            self.sendVerifyButton.isUserInteractionEnabled = (phone.count > 0) ? true : false
        }
    }
    
    @IBAction func phoneCodeButtonPress(_ sender: IBInspectableButton) {
        if self.phoneCodeArray.count == 0 {
            apiGetPhoneCode { [unowned self] in
                self.showPhoneCodePicker()
            }
            return
        }
        
        showPhoneCodePicker()
    }
    
    @IBAction func sendVerifyCodeOnClick(_ sender: IBInspectableButton) {
        if !textField.text!.validateCellphone() {
            SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_LI_031"), alertMessage: LocalizedString("Lang_LI_032"), buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
            return
        }
        sendVerify()
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
    
    private func sendVerify() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            if SystemManager.getAppIdentity() == .SalonWalker {
                MemberManager.apiSetVerify(confirmType: "1", internationalPrefix: phoneCode, phone: textField.text!, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        if let mId = model?.data?.mId {
                            UserManager.sharedInstance.mId = mId
                            self.goToEnterVerifyVCWithVerifyCode()
                        }
                        self.hideLoading()
                    } else {
                        self.endLoadingWith(model: model)
                    }
                    }, failure: { (error) in
                        SystemManager.showErrorAlert(error: error)
                })
            } else {
                OperatingManager.apiSetVerify(confirmType: "1", internationalPrefix: phoneCode, phone: textField.text!, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        if let ouId = model?.data?.ouId {
                            UserManager.sharedInstance.ouId = ouId
                            self.goToEnterVerifyVCWithVerifyCode()
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
