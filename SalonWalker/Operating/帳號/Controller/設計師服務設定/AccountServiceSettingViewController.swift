//
//  AccountServiceSettingViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum StatusButtonType {
    case save       //儲存
    case edit       //編輯
    case cancel     //取消
    case delete     //刪除
}

class AccountServiceSettingViewController: BaseViewController {
    
    @IBOutlet weak var naviRightButton: UIButton!
    @IBOutlet weak private var topMenuView: TopMenuView!
    @IBOutlet weak private var scrollView: UIScrollView!
    
    private var naviRightButtonType: StatusButtonType = .edit
    
    private let pageMenuControl = ScrollPageMenuControl()
    private let openTimeVC = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: OpenTimeViewController.self)) as! OpenTimeViewController
    private let servicePriceVC = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: ServicePriceViewController.self)) as! ServicePriceViewController
    private let serviceLocationVC = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: ServiceLocationViewController.self)) as! ServiceLocationViewController
    
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
    }
    
    // MARK: Method
    override func networkDidRecover() {
        callAPI()
    }
    
    private func initialize() {
        serviceLocationVC.serviceLocationVCDelegate = self
        pageMenuControl.setupPageViewWith(topView: topMenuView, scrollView: scrollView, titles: [LocalizedString("Lang_AC_041"),LocalizedString("Lang_AC_042"),LocalizedString("Lang_RD_022")], childVCs: [openTimeVC,servicePriceVC,serviceLocationVC], baseVC: self, delegate: self, showBorder: true)
    }
    
    private func callAPI() {
        switch pageMenuControl.getCurrentPage() {
        case 0: openTimeVC.callAPI()
            break
        case 1: servicePriceVC.callAPI()
            break
        case 2: serviceLocationVC.callAPI()
            break
        default: break
        }
    }
    
    // MARK: Event Handler
    @IBAction func naviRightButtonClick(_ sender: UIButton) {
        if pageMenuControl.getCurrentPage() == 0 {
            openTimeVC.naviRightButtonClick()
        }
        
        if pageMenuControl.getCurrentPage() == 2 {
            serviceLocationVC.naviRightButtonClick(naviRightButtonType: naviRightButtonType)
            switch naviRightButtonType {
            case .edit:
                naviRightButton.setTitle(LocalizedString("Lang_GE_060"), for: .normal)
                naviRightButtonType = .cancel
                break
            case .cancel:
                naviRightButton.setTitle(LocalizedString("Lang_GE_058"), for: .normal)
                naviRightButtonType = .edit
                break
            case .delete: break
            default: break
            }
        }
    }
}

extension AccountServiceSettingViewController:ScrollPageMenuControlDelegate {
    func didSelectetPageAt(_ pageIndex: Int) {
        pageMenuControl.changeCurrentPage(pageIndex)
        switch pageIndex {
        case 0:
            naviRightButton.setTitle(LocalizedString("Lang_GE_026"), for: .normal)
            naviRightButton.isHidden = false
        case 1:
            naviRightButton.isHidden = true
        case 2:
            if naviRightButtonType == .edit {
                naviRightButton.setTitle(LocalizedString("Lang_GE_058"), for: .normal)
            } else if naviRightButtonType == .cancel {
                naviRightButton.setTitle(LocalizedString("Lang_GE_060"), for: .normal)
            } else {
                naviRightButton.setTitle(LocalizedString("Lang_GE_059"), for: .normal)
            }
            naviRightButton.isHidden = false
        default:
            break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [unowned self] in
            self.callAPI()
        })
    }
}

extension AccountServiceSettingViewController: ServiceLocationViewControllerDelegate {
    func changeNaviRightButtonTitleWith(selectSvcPlaceCount: Int) {
        if selectSvcPlaceCount != 0 {
            self.naviRightButton.setTitle(LocalizedString("Lang_GE_059"), for: .normal)
            self.naviRightButtonType = .delete
        } else {
            self.naviRightButton.setTitle(LocalizedString("Lang_GE_060"), for: .normal)
            self.naviRightButtonType = .cancel
        }
    }
}
