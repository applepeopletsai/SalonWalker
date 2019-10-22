//
//  SettingHomePageViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/19.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

let kRefreshUIAfterLoginout = "RefreshUIAfterLoginout"

class SettingHomePageViewController: BaseViewController {
    
    @IBOutlet private weak var personalImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var phoneLabel: UILabel!
    @IBOutlet private weak var reservationWarnSwitch: UISwitch!
    @IBOutlet private weak var exerciseAndAnnouncementSwitch: UISwitch!
    @IBOutlet private weak var GPSAutoDetectSwitch: UISwitch!
    @IBOutlet private weak var browseRecordSwitch: UISwitch!
    @IBOutlet private weak var languageAndRegionLabel: IBInspectableLabel!
    @IBOutlet private weak var versionNumberLabel: UILabel!
    @IBOutlet private weak var GPSViewTopSpace: NSLayoutConstraint!
    @IBOutlet private weak var GPSDetectViewHeight: NSLayoutConstraint!
    
    private var memberInfoModel: MemberInfoModel?
    private var designerInfoModel: DesignerInfoModel?
    private var providerInfoModel: ProviderInfoModel?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.personalImageView.layer.cornerRadius = self.personalImageView.bounds.width / 2
    }
    
    // MARK: Method
    func setupVCWith<T: Codable>(model: T?) {
        if model is MemberInfoModel {
            self.memberInfoModel = model as? MemberInfoModel
        }
        if model is DesignerInfoModel {
            self.designerInfoModel = model as? DesignerInfoModel
        }
        if model is ProviderInfoModel {
            self.providerInfoModel = model as? ProviderInfoModel
        }
    }
    
    private func initializeUI() {
        if UserManager.sharedInstance.userIdentity != .designer {
            GPSDetectViewHeight.constant = 0
            GPSViewTopSpace.constant = 0
            languageAndRegionLabel.text = LocalizedString("Lang_ST_026")
        }
        
        GPSAutoDetectSwitch.isOn = UserManager.getGPSAutoDetect()
        browseRecordSwitch.isOn = UserManager.getBrowsingRecord()
        
        
        #if DEV || UAT
        self.versionNumberLabel.text = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String
        #else
        self.versionNumberLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        #endif
    }
    
    private func setupUI() {
        if let model = memberInfoModel {
            self.nameLabel.text = model.nickName
            self.emailLabel.text = model.email
            self.phoneLabel.text = "(+\(model.internationalPrefix)) \(model.phone)"
            self.reservationWarnSwitch.isOn = model.reminder
            self.exerciseAndAnnouncementSwitch.isOn = model.notice
            if let headerImgUrl = model.headerImgUrl, headerImgUrl.count > 0 {
                self.personalImageView.setImage(with: headerImgUrl)
            }
        }
        if let model = designerInfoModel {
            self.nameLabel.text = model.nickName
            self.emailLabel.text = model.email
            self.phoneLabel.text = "(+\(model.internationalPrefix)) \(model.phone)"
            self.reservationWarnSwitch.isOn = model.reminder
            self.exerciseAndAnnouncementSwitch.isOn = model.notice
            if let imgUrl = model.headerImg?.imgUrl, imgUrl.count > 0 {
                self.personalImageView.setImage(with: imgUrl)
            }
        }
        if let model = providerInfoModel {
            self.nameLabel.text = model.nickName
            self.emailLabel.text = model.email
            self.phoneLabel.text = "\(model.telArea)-\(model.tel)"
            self.reservationWarnSwitch.isOn = model.reminder
            self.exerciseAndAnnouncementSwitch.isOn = model.notice
            if let imgUrl = model.headerImg?.imgUrl, imgUrl.count > 0 {
                self.personalImageView.setImage(with: imgUrl)
            }
        }
    }
    
    // MARK: EventHandler
    @IBAction func personalDataButtonClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "AccountSettingViewController") as! AccountSettingViewController
        if UserManager.sharedInstance.userIdentity == .consumer {
           vc.setupVCWithModel(model: memberInfoModel, target: self)
        } else if UserManager.sharedInstance.userIdentity == .designer {
            vc.setupVCWithModel(model: designerInfoModel, target: self)
        } else {
           vc.setupVCWithModel(model: providerInfoModel, target: self)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func reservationWarnSwitchClick(_ sender: UISwitch) {
        changeSetting(sender)
    }
    
    @IBAction func exerciseSwitchClick(_ sender: UISwitch) {
        changeSetting(sender)
    }
    
    @IBAction func GPSSwitchClick(_ sender: UISwitch) {
        UserManager.saveGPSAutoDetect(sender.isOn)
    }
    
    @IBAction func languageSettingButtonClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "LanguageSettingViewController") as! LanguageSettingViewController
        if let slId = memberInfoModel?.slId {
            vc.setupVCWith(slId: slId, delegate: self)
        }
        if let slId = designerInfoModel?.slId {
            vc.setupVCWith(slId: slId, delegate: self)
        }
        if let slId = providerInfoModel?.slId {
            vc.setupVCWith(slId: slId, delegate: self)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func feedbackButtonPress(_ sender: UISwitch) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: FeedbackViewController.self)) as! FeedbackViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func browseRecordSwitchClick(_ sender: UISwitch) {
        UserManager.saveBrowsingRecord(sender.isOn)
    }
    
    @IBAction func clearBrowseRecordButtonClick(_ sender: UIButton) {
        SystemManager.showTwoButtonAlertWith(alertTitle: LocalizedString("Lang_ST_028"), alertMessage: nil, leftButtonTitle: LocalizedString("Lang_GE_060"), rightButtonTitle: LocalizedString("Lang_GE_027"), leftHandler: nil, rightHandler: {
            UserManager.deleteRecentSearches()
        })
    }
    
    @IBAction private func logoutButtonPress(_ sender: UIButton) {
        SystemManager.showTwoButtonAlertWith(alertTitle: LocalizedString("Lang_GE_063"), alertMessage: nil, leftButtonTitle: LocalizedString("Lang_GE_060"), rightButtonTitle: LocalizedString("Lang_GE_027"), leftHandler: nil, rightHandler: { [weak self] in
            if UserManager.sharedInstance.userIdentity == .consumer {
                self?.apiMemberLogout()
            } else {
                self?.apiOperatingLogout()
            }
        })
    }
    
    // MARK: API
    private func changeSetting(_ sender: UISwitch) {
        if UserManager.sharedInstance.userIdentity == .consumer {
            apiSetMemberSetting(sender)
        } else {
            apiSetOperatingSetting(sender)
        }
    }
    
    private func apiSetMemberSetting(_ sender: UISwitch) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            MemberManager.apiSetMemberSetting(reminder: reservationWarnSwitch.isOn, notice: exerciseAndAnnouncementSwitch.isOn, success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    self.hideLoading()
                } else {
                    sender.isOn = !sender.isOn
                    self.endLoadingWith(model: model)
                }
                
                }, failure: { (error) in
                    sender.isOn = !sender.isOn
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiSetOperatingSetting(_ sender: UISwitch) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            OperatingManager.apiSetOperatingSetting(reminder: reservationWarnSwitch.isOn, notice: exerciseAndAnnouncementSwitch.isOn, success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    self.hideLoading()
                } else {
                    sender.isOn = !sender.isOn
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                sender.isOn = !sender.isOn
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiMemberLogout() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            MemberManager.apiLogut(success: { (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRefreshUIAfterLoginout), object: nil)
                    UserManager.sharedInstance.mId = nil
                    UserManager.deleteLastLoginType()
                    UserManager.deleteUserToken()
                    SystemManager.changeTabBarSelectIndex(index: 0, pop: true)
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiOperatingLogout() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            OperatingManager.apiLogut(success: { (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    UserManager.deleteLastLoginType()
                    UserManager.deleteUserToken()
                    SystemManager.backToLoginVC()
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension SettingHomePageViewController: LanguageSettingViewControllerDelegate {
    func didChangeLang(_ slId: Int) {
        self.memberInfoModel?.slId = slId
        self.designerInfoModel?.slId = slId
        self.providerInfoModel?.slId = slId
    }
}

extension SettingHomePageViewController: AccountSettingViewControllerDelegate {
    
    func infoDidChange<T>(model: T?) {
        if model is MemberInfoModel{
            self.memberInfoModel = model as? MemberInfoModel
        }
        if model is DesignerInfoModel{
            self.designerInfoModel = model as? DesignerInfoModel
        }
        if model is ProviderInfoModel{
            self.providerInfoModel = model as? ProviderInfoModel
        }
        self.setupUI()
    }
    
}
