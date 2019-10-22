//
//  ChangePasswordViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/19.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ChangePasswordViewController: BaseViewController {
    
    @IBOutlet weak var originPasswordTextField: IBInspectableTextField!
    @IBOutlet weak var newPasswordTextField: IBInspectableTextField!
    @IBOutlet weak var againPasswordTextField: IBInspectableTextField!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: EventHandler
    @IBAction func dismissButtonClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonClick(_ sender: UIButton) {
        if originPasswordTextField.text?.count == 0 {
            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_ST_019"), body: "")
            return
        }
        if newPasswordTextField.text?.count == 0 {
            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_ST_018"), body: "")
            return
        }
        if newPasswordTextField.text != againPasswordTextField.text {
            PresentationTool.showNoButtonAlertWith(image: UIImage(named: "img_wrongnpw"), message: LocalizedString("Lang_ST_021"), completion: nil)
            return
        }
        if let password = newPasswordTextField.text {
            if !password.validatePassword() {
                SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_LI_029"), alertMessage: LocalizedString("Lang_LI_030"), buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
                return
            }
        }
        apiResetPsd()
    }
    
    // API
    func apiResetPsd() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            if UserManager.sharedInstance.userIdentity == .consumer {
                
                MemberManager.apiResetPsd(opsd: originPasswordTextField.text, psd: newPasswordTextField.text!, success: { [unowned self] (model) in
                    
                    if model?.syscode == 200 {
                        self.hideLoading()
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        if let sysmsg = model?.sysmsg {
                            PresentationTool.showNoButtonAlertWith(image: UIImage(named: "img_wrongpw"), message: sysmsg, completion: nil)
                            self.hideLoading()
                        } else {
                            self.endLoadingWith(model: model)
                        }
                    }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
                })
                
            } else {
                OperatingManager.apiResetPsd(opsd: originPasswordTextField.text, psd: newPasswordTextField.text!, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        self.hideLoading()
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        if let sysmsg = model?.sysmsg {
                            PresentationTool.showNoButtonAlertWith(image: UIImage(named: "img_wrongpw"), message: sysmsg, completion: nil)
                            self.hideLoading()
                        } else {
                            self.endLoadingWith(model: model)
                        }
                    }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
                })
            }
        }
    }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    
}
