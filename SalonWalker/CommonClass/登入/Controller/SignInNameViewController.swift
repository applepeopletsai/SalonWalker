//
//  SignInNameViewController.swift
//  SalonWalker
//
//  Created by skywind on 2018/3/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class SignInNameViewController: BaseViewController {

    @IBOutlet private weak var textfield: IBInspectableTextField!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var agreeTermsLabel: UILabel!
    
    private var nickName: String? = UserManager.sharedInstance.nickName
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextField()
        self.setupDoneButton()
        self.setupLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupTextField() {
        var placeHolderKey = ""
        
        if let userIdentity = UserManager.sharedInstance.userIdentity {
            switch userIdentity {
            case .consumer:
                placeHolderKey = "Lang_LI_018"
                break
            case .designer:
                placeHolderKey = "Lang_LI_019"
                break
            case .store:
                placeHolderKey = "Lang_LI_020"
                break
            }
        }

        textfield.placeHolderLocolizedKey = placeHolderKey
        textfield.addTarget(self, action: #selector(textDidChange(_:)), for: .allEditingEvents)
        
        textfield.text = self.nickName
    }
    
    private func setupDoneButton() {
        if let text = textfield.text {
            self.doneButton.backgroundColor = (text.count > 0) ? color_1A1C69 : color_AAAAAA
            self.doneButton.isUserInteractionEnabled = (text.count > 0) ? true : false
        }
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
        if let text = textField.text {
            self.setupDoneButton()
            self.nickName = text
        }
    }
    
    @IBAction private func doneButtonPress(_ sender: UIButton) {
        UserManager.sharedInstance.nickName = nickName
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "VerifyTelphoneViewController") as! VerifyTelphoneViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SignInNameViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let totalString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if let totalString = totalString, totalString.count > 10 {
            return false
        }
        return true
    }
}

