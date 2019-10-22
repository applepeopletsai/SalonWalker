//
//  AccountViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/22.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class AccountViewController: BaseViewController {

    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var memberNameLabel: UILabel!
    @IBOutlet private weak var cautionCountLabel: UILabel!
    @IBOutlet private weak var missCountLabel: UILabel!
    @IBOutlet private weak var pushCountLabel: UILabel!
    @IBOutlet private weak var pushCountView: UIView!
    
    private var memberInfoModel: MemberInfoModel?
    private var headshot: MultipleAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        apiGetMemberInfo()
    }
    
    // Method
    override func networkDidRecover() {
        apiGetMemberInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.photoImageView.layer.cornerRadius = self.photoImageView.bounds.size.width / 2
    }
    
    private func setupUI() {
        if let model = memberInfoModel {
            self.memberNameLabel.text = model.nickName
            self.cautionCountLabel.text = String(model.cautionTotal)
            self.missCountLabel.text = String(model.missTotal)
            
            if model.pushTotal > 0 {
                self.pushCountView.isHidden = false
                self.pushCountLabel.isHidden = false
                self.pushCountLabel.text = String(model.pushTotal.transferToDecimalString())
            } else {
                self.pushCountView.isHidden = true
                self.pushCountLabel.isHidden = true
            }
            
            if let headerImgUrl = model.headerImgUrl, headerImgUrl.count > 0 {
                self.photoImageView.setImage(with: headerImgUrl)
            }
        }
    }
    
    private func showWarningList(type: WarningListType) {
        guard let data = (type == .caution) ? memberInfoModel?.cautionDetail : memberInfoModel?.missDetail else { return }
        if data.count == 0 { return }
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: WarningListViewController.self)) as! WarningListViewController
        vc.setupVCWith(data: data, type: type)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Event Handler
    @IBAction private func missButtonPress(_ sender: UIButton) {
        showWarningList(type: .miss)
    }
    
    @IBAction private func cautionButtonPress(_ sender: UIButton) {
        showWarningList(type: .caution)
    }
    
    @IBAction private func settingButtonPress(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: String(describing: SettingHomePageViewController.self)) as! SettingHomePageViewController
        vc.setupVCWith(model: memberInfoModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func myCalendarButtonPress(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: MyCalendarViewController.self)) as! MyCalendarViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func orderRecordButtonPress(_ sender: UIButton) {
        let vc = UIStoryboard(name: kStory_Account, bundle: nil).instantiateViewController(withIdentifier: String(describing: OrderRecordViewController.self)) as! OrderRecordViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func transactionTermsButtonPress(_ sender: UIButton) {
        SystemManager.openTransactionTerms()
    }
    
    @IBAction private func harborListButtonPress(_ sender: UIButton) {
        let vc = UIStoryboard(name: kStory_HomePage, bundle: nil).instantiateViewController(withIdentifier: String(describing: HarborListViewController.self)) as! HarborListViewController
        vc.showNavigation(true)
        self.navigationController?.pushViewController(vc, animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                vc.callAPI()
            })
        })
    }
    
    @IBAction private func pushListButtonPress(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: NotificationListViewController.self)) as! NotificationListViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func fbButtonPress(_ sender: UIButton) {
        SystemManager.openSalonWalkerFB()
    }
    
    @IBAction private func igButtonPress(_ sender: UIButton) {
        SystemManager.openSalonWalkerIG()
    }
    
    // MARK: API
    private func apiGetMemberInfo() {
        if SystemManager.isNetworkReachable() {
            if memberInfoModel == nil { self.showLoading() }
            
            MemberManager.apiGetMemberInfo(success: { [weak self] (model) in
                
                if model?.syscode == 200 {
                    if let status = model?.data?.status {
                        UserManager.sharedInstance.accountStatus = AccountStatus(rawValue: status)
                    }
                    UserManager.sharedInstance.penalty = model?.data?.penalty
                    self?.memberInfoModel = model?.data
                    self?.setupUI()
                    self?.removeMaskView()
                    self?.hideLoading()
                } else {
                    self?.endLoadingWith(model: model)
                }
                
            }, failure: { [weak self] (error) in
                self?.removeMaskView()
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}
