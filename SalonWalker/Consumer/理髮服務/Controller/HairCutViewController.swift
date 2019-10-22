//
//  HairCutViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/22.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class HairCutViewController: BaseViewController {

    @IBOutlet private weak var topView: TopMenuView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var penaltyView: UIView!
    @IBOutlet private weak var penaltyViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var penaltyLabel: UILabel!
    
    private let pageMenuControl = ScrollPageMenuControl()
    private let rankingVC = UIStoryboard(name: kStory_HairCut, bundle: nil).instantiateViewController(withIdentifier: String(describing: FullSiteRankingViewController.self)) as! FullSiteRankingViewController
    private let nearbyVC = UIStoryboard(name: kStory_HairCut, bundle: nil).instantiateViewController(withIdentifier: String(describing: NearByViewController.self)) as! NearByViewController
    private let customVC = UIStoryboard(name: kStory_HairCut, bundle: nil).instantiateViewController(withIdentifier: String(describing: CustomViewController.self)) as! CustomViewController
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePenaltyView()
        setupPageMenu()
        addObserver()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
            self.checkRecentSearchData()
            self.callAPI()
        }
        checkAccountStatus()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageMenuControl.resizeFrame()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Method
    override func networkDidRecover() {
        callAPI()
    }
    
    private func setupPageMenu() {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        // 暫時解決第一次進來畫面會定格的問題
        self.showLoading()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) { [unowned self] in
            self.pageMenuControl.setupPageViewWith(topView: self.topView, scrollView: self.scrollView, titles: [LocalizedString("Lang_HM_029"), LocalizedString("Lang_HM_030"), LocalizedString("Lang_HM_031")], childVCs: [self.rankingVC, self.nearbyVC, self.customVC], baseVC: self, delegate: self)
        }
    }
    
    private func configurePenaltyView() {
        self.penaltyView.gestureRecognizers?.removeAll()
        if UserManager.sharedInstance.accountStatus == .suspend_temporary ||
            UserManager.sharedInstance.accountStatus == .suspend_permanent {
            if let penalty = UserManager.sharedInstance.penalty {
                self.penaltyLabel.text = penalty.title
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchPenaltyView))
                gestureRecognizer.numberOfTapsRequired = 1
                self.penaltyView.addGestureRecognizer(gestureRecognizer)
            } else {
                self.penaltyViewHeight.constant = 0
            }
        } else {
            self.penaltyViewHeight.constant = 0
        }
    }
    
    @objc private func touchPenaltyView() {
        PresentationTool.showNoButtonAlertWith(image: UIImage(named: "img_pop_warning"), message: UserManager.sharedInstance.penalty!.msg, autoDismiss: false, completion: nil)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(gotoRankingVC), name: NSNotification.Name(kGoToRankingVC), object: nil)
    }
    
    @objc private func gotoRankingVC() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
            self.pageMenuControl.changeCurrentPage(0)
        }
    }
    
    private func callAPI() {
        switch pageMenuControl.getCurrentPage() {
        case 0:
            self.rankingVC.callAPI()
            break
        case 1:
            self.nearbyVC.callAPI()
            break
        default: break
        }
    }
    
    private func checkRecentSearchData() {
        switch pageMenuControl.getCurrentPage() {
        case 0:
            self.rankingVC.checkRecentSearchData()
            break
        case 1:
            self.nearbyVC.checkRecentSearchData()
            break
        default: break
        }
    }
    
    private func checkAccountStatus() {
        // 檢查帳號狀態
        MemberManager.apiGetMemberInfo(success: { [weak self] (model) in
            if model?.syscode == 200 {
                if let status = model?.data?.status {
                    UserManager.sharedInstance.accountStatus = AccountStatus(rawValue: status)
                }
                UserManager.sharedInstance.penalty = model?.data?.penalty
                self?.configurePenaltyView()
            }
            }, failure: { _ in })
    }
}

extension HairCutViewController: ScrollPageMenuControlDelegate {
    
    func didSelectetPageAt(_ pageIndex: Int) {
        pageMenuControl.changeCurrentPage(pageIndex)
        checkRecentSearchData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [unowned self] in
            self.callAPI()
        })
    }
}

