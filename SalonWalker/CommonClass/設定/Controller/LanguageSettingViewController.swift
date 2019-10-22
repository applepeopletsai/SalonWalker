//
//  LanguageSettingViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/19.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol LanguageSettingViewControllerDelegate: class {
    func didChangeLang(_ slId: Int)
}

class LanguageSettingViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var languageArray: [LangModel] = []
    private var selectSlId: Int = 1
    private weak var delegate: LanguageSettingViewControllerDelegate?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
        apiGetSystemLang()
    }
    
    // MARK: Method
    override func networkDidRecover() {
        if languageArray.count == 0 {
            apiGetSystemLang()
        }
    }
    
    func setupVCWithSelectSlId(_ slId: Int) {
        self.selectSlId = slId
    }
    
    func setupVCWith(slId: Int, delegate: LanguageSettingViewControllerDelegate) {
        self.selectSlId = slId
        self.delegate = delegate
    }
    
    // MARK: API
    private func apiGetSystemLang() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            SystemManager.apiGetSystemLang(success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    if let lang = model?.data?.lang {
                        self.languageArray = lang
                    }
                    self.tableView.reloadData()
                    self.hideLoading()
                    self.removeMaskView()
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { [unowned self] (error) in
                self.removeMaskView()
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    private func apiSetMemberLangSetting(slId: Int) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            MemberManager.apiSetMemberLangSetting(slId: slId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.selectSlId = slId
                    self.tableView.reloadData()
                    self.hideLoading()
                    self.delegate?.didChangeLang(slId)
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiSetOperatingLangSetting(slId: Int) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            OperatingManager.apiSetOperatingLangSetting(slId: slId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.selectSlId = slId
                    self.tableView.reloadData()
                    self.hideLoading()
                    self.delegate?.didChangeLang(slId)
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
}
extension LanguageSettingViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageSettingTableViewCell", for: indexPath) as! LanguageSettingTableViewCell
        let isSelect = (selectSlId == languageArray[indexPath.row].slId)
        cell.setupCellWith(languageModel: languageArray[indexPath.row], isSelect: isSelect)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let slId = languageArray[indexPath.row].slId
        if selectSlId == slId { return }
        if UserManager.sharedInstance.userIdentity == .consumer {
            apiSetMemberLangSetting(slId: slId)
        } else {
            apiSetOperatingLangSetting(slId: slId)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
