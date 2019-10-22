//
//  ResetPasswordViewController.swift
//  SalonWalker
//
//  Created by skywind on 2018/3/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ResetPasswordViewController: BaseViewController {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupColor()
        setupTextField()
    }

    private func setupColor() {
        if SystemManager.getAppIdentity() == .SalonWalker {
            colorView.backgroundColor = color_E1FFF4
        }else{
            colorView.backgroundColor = color_7A57FA
        }
    }

    private func setupTextField() {
        newPasswordTextField.addTarget(self, action: #selector(textDidChange(_:)), for: .allEditingEvents)
        confirmPasswordTextField.addTarget(self, action: #selector(textDidChange(_:)), for: .allEditingEvents)
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        if let newPassword = newPasswordTextField.text, let confirmPassword = confirmPasswordTextField.text {
            self.confirmPasswordButton.backgroundColor = (newPassword.count > 0 && confirmPassword.count > 0) ? color_1A1C69 : color_AAAAAA
            self.confirmPasswordButton.isUserInteractionEnabled = (newPassword.count > 0 && confirmPassword.count > 0) ? true : false
        }
    }
    
    @IBAction func sendVerifyOnClick(_ sender: Any) {
        let newPassword = newPasswordTextField.text!
        let confirmPassword = confirmPasswordTextField.text!
        
        if newPassword != confirmPassword {
            SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_LI_026"), alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
            return
        }
        
        if !newPassword.validatePassword() || !confirmPassword.validatePassword() {
            SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_LI_029"), alertMessage: LocalizedString("Lang_LI_030"), buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
            return
        }
        
        apiResetPassword()
    }
    
    //MARK: API
    private func apiResetPassword() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            if SystemManager.getAppIdentity() == .SalonWalker {
                MemberManager.apiResetPsd(opsd: nil, psd: newPasswordTextField.text!, success: { [unowned self] (model) in
                    
                    if model?.syscode == 200 {
                        SystemManager.showAlertWith(alertTitle: model?.data?.msg, alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: {
                            self.navigationController?.popToRootViewController(animated: true)
                        })
                        self.hideLoading()
                    } else {
                        self.endLoadingWith(model: model)
                    }
                    }, failure: { (error) in
                        SystemManager.showErrorAlert(error: error)
                })
            } else {
                OperatingManager.apiResetPsd(opsd: nil, psd: newPasswordTextField.text!, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        SystemManager.showAlertWith(alertTitle: model?.data?.msg, alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: {
                            self.navigationController?.popToRootViewController(animated: true)
                        })
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
