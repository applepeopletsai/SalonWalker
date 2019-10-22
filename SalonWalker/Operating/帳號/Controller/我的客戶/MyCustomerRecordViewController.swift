//
//  MyCustomerRecordViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class MyCustomerRecordViewController: BaseViewController {
    
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var topMenuView: TopMenuView!
    @IBOutlet private weak var naviTitleLabel: UILabel!
    @IBOutlet private weak var customerNameLabel: UILabel!
    @IBOutlet private weak var customerImageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var customerBaseViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var imageViewHeight: NSLayoutConstraint!
    
    private let pageMenuControl = ScrollPageMenuControl()
    private let hairTypeVC = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: PersonalHairDataViewController.self)) as! PersonalHairDataViewController
    private let requireRecordVC = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: RequireRecordViewController.self)) as! RequireRecordViewController
    private let consumeRecordVC = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: ConsumeRecordViewController.self)) as! ConsumeRecordViewController
    
    private var mId: Int?
    private var nickName: String?
    private var headerImgUrl: String?
    private var customerDataModel: CustomerDataModel?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageMenuControl.resizeFrame()
        self.customerImageView.layer.cornerRadius = self.customerImageView.bounds.width / 2
    }
    
    // MARK: Method
    override func networkDidRecover() {
        callAPI()
    }
    
    func setupVCWith(mId: Int, nickName: String, headerImgUrl: String) {
        self.mId = mId
        self.nickName = nickName
        self.headerImgUrl = headerImgUrl
    }
    
    private func initialize() {
        if SizeTool.isIphone5() {
            customerBaseViewHeight.constant = 75
            imageViewHeight.constant = 50
        }
        
        self.naviTitleLabel.text = nickName
        self.customerNameLabel.text = nickName
        if let url = headerImgUrl, url.count > 0 {
            self.customerImageView.setImage(with: url)
        }
        
        hairTypeVC.setupVCWith(mId: mId, delegate: self)
        requireRecordVC.setupVCWith(mId: mId)
        consumeRecordVC.setupVCWith(mId: mId)
        pageMenuControl.setupPageViewWith(topView: topMenuView, scrollView: scrollView, titles: [LocalizedString("Lang_DD_001"),LocalizedString("Lang_AC_023"),LocalizedString("Lang_AC_024")], childVCs: [hairTypeVC,requireRecordVC,consumeRecordVC], baseVC: self, delegate: self, showBorder: true)
    }
    
    private func callAPI() {
        switch pageMenuControl.getCurrentPage() {
        case 0:
            hairTypeVC.callAPI()
            break
        case 1:
            requireRecordVC.callAPI()
            break
        case 2:
            consumeRecordVC.callAPI()
            break
        default: break
        }
    }
    
    // MARK: Event Handler
    @IBAction func saveButtonClick(_ sender: UIButton) {
        apiSetCustomerData()
    }
    
    // MARK: API
    private func apiSetCustomerData() {
        guard let model = customerDataModel else { return }
        
        if SystemManager.isNetworkReachable() {
            
            self.showLoading()
            
            CustomerManager.apiSetCustomerData(mId: model.mId, hairType: model.hairType, scalp: model.scalp, success: { (model) in
                
                if model?.syscode == 200 {
                    SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_GE_021"), body: "")
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
}

extension MyCustomerRecordViewController: ScrollPageMenuControlDelegate  {
    
    func didSelectetPageAt(_ pageIndex: Int) {
        pageMenuControl.changeCurrentPage(pageIndex)
        saveButton.isHidden = (pageIndex != 0) ? true : false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [unowned self] in
            self.callAPI()
        })
    }
}

extension MyCustomerRecordViewController: PersonalHairDataViewControllerDelegate {
    
    func changeCustomerData(model: CustomerDataModel, dataChanged: Bool) {
        saveButton.isEnabled = dataChanged
        customerDataModel = model
    }
}

