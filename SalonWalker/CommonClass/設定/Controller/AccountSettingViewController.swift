//
//  AccountSettingViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/19.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol AccountSettingViewControllerDelegate: class {
    func infoDidChange<T: Codable>(model: T?)
}

class AccountSettingViewController: BaseViewController {
    
    @IBOutlet private weak var personalImageView: UIImageView!
    @IBOutlet private weak var nameTextField: IBInspectableTextField!
    @IBOutlet private weak var accountLabel: UILabel!
    @IBOutlet private weak var cellPhoneLabel: UILabel!
    @IBOutlet private weak var accountViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var passwordViewHeight: NSLayoutConstraint!
    
    private var memberInfoModel: MemberInfoModel?
    private var designerInfoModel: DesignerInfoModel?
    private var providerInfoModel: ProviderInfoModel?
    private var headshot: MultipleAsset?
    private var headerImgId: Int?
    
    private weak var delegate: AccountSettingViewControllerDelegate?
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addObser()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.personalImageView.layer.cornerRadius = self.personalImageView.bounds.width / 2
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Method
    func setupVCWithModel<T: Codable>(model: T?, target: AccountSettingViewControllerDelegate) {
        if model is MemberInfoModel {
            self.memberInfoModel = model as? MemberInfoModel
        }
        if model is DesignerInfoModel {
            self.designerInfoModel = model as? DesignerInfoModel
        }
        if model is ProviderInfoModel {
            self.providerInfoModel = model as? ProviderInfoModel
        }
        self.delegate = target
    }
    
    private func setupUI() {
        self.personalImageView.image = UIImage(named: "img_account_user")
        
        if UserManager.sharedInstance.loginType != .general {
            self.accountViewHeight.constant = 0
            self.passwordViewHeight.constant = 0
        }
        
        if let model = memberInfoModel {
            self.nameTextField.text = model.nickName
            self.accountLabel.text = model.email
            self.cellPhoneLabel.text = "(+\(model.internationalPrefix)) \(model.phone)"
            if let headerImgUrl = model.headerImgUrl, headerImgUrl.count > 0 {
                self.personalImageView.setImage(with: headerImgUrl)
            }
        }
        if let model = designerInfoModel {
            self.nameTextField.text = model.nickName
            self.accountLabel.text = model.email
            self.cellPhoneLabel.text = "(+\(model.internationalPrefix)) \(model.phone)"
            if let imgUrl = model.headerImg?.imgUrl, imgUrl.count > 0 {
                self.personalImageView.setImage(with: imgUrl)
            }
        }
        if let model = providerInfoModel {
            self.nameTextField.text = model.nickName
            self.accountLabel.text = model.email
            self.cellPhoneLabel.text = "(+\(model.internationalPrefix)) \(model.phone)"
            if let imgUrl = model.headerImg?.imgUrl, imgUrl.count > 0 {
                self.personalImageView.setImage(with: imgUrl)
            }
        }
    }
    
    private func addObser() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangePhoneNumber(_:)), name: NSNotification.Name(rawValue: kChangePhoneNumber), object: nil)
    }
    
    @objc private func didChangePhoneNumber(_ noti: Notification) {
        if let internationalPrefix = noti.userInfo?["internationalPrefix"] as? String, let phone = noti.userInfo?["phone"] as? String {
            if UserManager.sharedInstance.userIdentity == .consumer {
                self.memberInfoModel?.internationalPrefix = internationalPrefix
                self.memberInfoModel?.phone = phone
                self.cellPhoneLabel.text = "(+\(internationalPrefix)) \(phone)"
                self.delegate?.infoDidChange(model: memberInfoModel)
            } else if UserManager.sharedInstance.userIdentity == .designer {
                self.designerInfoModel?.internationalPrefix = internationalPrefix
                self.designerInfoModel?.phone = phone
                self.cellPhoneLabel.text = "(+\(internationalPrefix)) \(phone)"
                self.delegate?.infoDidChange(model: designerInfoModel)
            } else {
                self.providerInfoModel?.internationalPrefix = internationalPrefix
                self.providerInfoModel?.phone = phone
                self.cellPhoneLabel.text = "(+\(internationalPrefix)) \(phone)"
                self.delegate?.infoDidChange(model: providerInfoModel)
            }
        }
    }
    
    // MARK: EventHandler
    @IBAction func saveButtonClick(_ sender: UIButton) {
        if nameTextField.text?.count == 0 {
            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_ST_029"), body: "")
            return
        }
        nameTextField.resignFirstResponder()
        if UserManager.sharedInstance.userIdentity == .consumer {
            apiSetMemberInfo()
        } else {
            apiSetOperatingData()
        }
    }
    
    @IBAction func cameraButtonClick(_ sender: UIButton) {
        var array: [MultipleAsset] = []
        if let headshot = headshot {
            array.append(headshot)
        }
        PresentationTool.showImagePickerWith(selectAssets: array, maxSelectCount: 1, showVideo: false, target: self)
    }
    
    @IBAction func changePhoneNumberButtonClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "ChangePhoneNumberViewController") as! ChangePhoneNumberViewController
        if let internationalPrefix = self.memberInfoModel?.internationalPrefix, let phone = self.memberInfoModel?.phone {
            vc.setupVCWith(phoneCode: internationalPrefix, phone: phone)
        }
        if let internationalPrefix = self.designerInfoModel?.internationalPrefix, let phone = self.designerInfoModel?.phone {
            vc.setupVCWith(phoneCode: internationalPrefix, phone: phone)
        }
        if let internationalPrefix = self.providerInfoModel?.internationalPrefix, let phone = self.providerInfoModel?.phone {
            vc.setupVCWith(phoneCode: internationalPrefix, phone: phone)
        }
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction private func changePasswordButtonClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
        present(vc, animated: true, completion: nil)
    }
    
    // MARK: API
    private func apiSetMemberInfo() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            MemberManager.apiSetMemberInfo(nickName: nameTextField.text!, headerImg: self.headerImgId, success: { [unowned self]  (model) in
                if model?.syscode == 200 {
                    self.memberInfoModel?.nickName = self.nameTextField.text!
                    self.delegate?.infoDidChange(model: self.memberInfoModel)
                    self.hideLoading()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiSetOperatingData() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            OperatingManager.apiSetOperatingData(nickName: nameTextField.text!, headerImg: self.headerImgId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.designerInfoModel?.nickName = self.nameTextField.text!
                    self.providerInfoModel?.nickName = self.nameTextField.text!
                    if UserManager.sharedInstance.userIdentity == .designer {
                        self.delegate?.infoDidChange(model: self.designerInfoModel)
                    } else {
                        self.delegate?.infoDidChange(model: self.providerInfoModel)
                    }
                    self.hideLoading()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.endLoadingWith(model: model)
                }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiTempImage(imageString: String? = nil) {
        self.showLoading()
        
        SystemManager.apiTempImage(imageType: "jpeg", image: imageString, fbImgUrl: nil, googleImgUrl: nil, tempImgId: nil, mId: UserManager.sharedInstance.mId, ouId: UserManager.sharedInstance.ouId, licenseImgId: nil, coverImgId: nil, act: "new", success: { [unowned self] (model) in
            
            if model?.syscode == 200 {
                self.headerImgId = model?.data?.tempImgId
                if let imgUrl = model?.data?.imgUrl, imgUrl.count > 0 {
                    self.memberInfoModel?.headerImgUrl = imgUrl
                    
                    if self.designerInfoModel?.headerImg == nil {
                        self.designerInfoModel?.headerImg = HeaderImg(imgUrl: imgUrl, headerImgId: nil, tempImgId: model?.data?.tempImgId, act: nil)
                    } else {
                        self.designerInfoModel?.headerImg?.imgUrl = imgUrl
                    }
                    if self.providerInfoModel?.headerImg == nil {
                        self.providerInfoModel?.headerImg = HeaderImg(imgUrl: imgUrl, headerImgId: nil, tempImgId: model?.data?.tempImgId, act: nil)
                    } else {
                        self.providerInfoModel?.headerImg?.imgUrl = imgUrl
                    }
                    self.personalImageView.setImage(with: imgUrl)
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

extension AccountSettingViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nameTextField {
            let totalString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            if let totalString = totalString, totalString.count > 10 {
                return false
            }
        }
        return true
    }
}

extension AccountSettingViewController: MultipleSelectImageViewControllerDelegate {
    func didSelectAssets(_ assets: [MultipleAsset]) {
        if SystemManager.isNetworkReachable() {
            
            if let asset = assets.first {
                asset.fetchOriginalImage(completeBlock: { [unowned self] (image, info) in
                    if let image = image {
                        self.headshot = asset
                        
                        self.showLoading()
                        image.resize(CGSize(width: 1024, height: 1024), completion: { (newImage) in
                            self.apiTempImage(imageString: newImage?.transformToBase64String(format: .jpeg(0.5)))
                        })
                    }
                })
            }
        }
    }
    
    func didCancel() {
        
    }
}
