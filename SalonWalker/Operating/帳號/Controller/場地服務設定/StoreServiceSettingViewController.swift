//
//  StoreServiceSettingViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/3.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class StoreServiceSettingViewController: BaseViewController {

    @IBOutlet private weak var topMenuView: TopMenuView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var saveButton: UIButton!
    
    private let pageMenuControl = ScrollPageMenuControl()
    private let paySchemeVC = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: StorePaySchemeViewController.self)) as! StorePaySchemeViewController
    private let openTimeVC = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: OpenTimeViewController.self)) as! OpenTimeViewController
    
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
        pageMenuControl.setupPageViewWith(topView: topMenuView, scrollView: scrollView, titles: [LocalizedString("Lang_HM_010"),LocalizedString("Lang_HM_011")], childVCs: [paySchemeVC,openTimeVC], baseVC: self, delegate: self, showBorder: true)
    }
    
    private func callAPI() {
        switch pageMenuControl.getCurrentPage() {
        case 0:
            paySchemeVC.callAPI()
            break
        case 1:
            openTimeVC.callAPI()
            break
        default: break
        }
    }
    
    // MARK: Event Handler
    @IBAction private func saveButtonPress(_ sender: UIButton) {
        openTimeVC.naviRightButtonClick()
    }
}

extension StoreServiceSettingViewController: ScrollPageMenuControlDelegate {
    func didSelectetPageAt(_ pageIndex: Int) {
        pageMenuControl.changeCurrentPage(pageIndex)
        saveButton.isHidden = (pageIndex == 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [unowned self] in
            self.callAPI()
        })
    }
}
