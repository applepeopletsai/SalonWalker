//
//  SiteOrderListMainViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/24.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class SiteOrderListMainViewController: BaseViewController {
    
    @IBOutlet private weak var topMenuView: TopMenuView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var naviTitleLabel: UILabel!
    
    private let pageMenuControl = ScrollPageMenuControl()
    private let bookVC = getOrderListVCWithType(.AlreadyBook)
    private let backDepositVC = getOrderListVCWithType(.BackDeposit)
    private let penaltyVC = getOrderListVCWithType(.AlreadyPenalty)
    private let doneVC = getOrderListVCWithType(.AlreadyDone)
    
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
    
    static private func getOrderListVCWithType(_ type: OperatingOrderRecordType) -> SiteOrderListViewController {
        let vc = UIStoryboard(name: "OrderRecord", bundle: nil).instantiateViewController(withIdentifier: String(describing: SiteOrderListViewController.self)) as! SiteOrderListViewController
        vc.setupVCWithListType(type)
        return vc
    }
    
    private func initialize() {
        self.naviTitleLabel.text = LocalizedString("Lang_RD_003")
        self.pageMenuControl.setupPageViewWith(topView: self.topMenuView, scrollView: self.scrollView, titles: [LocalizedString("Lang_RD_013"),LocalizedString("Lang_RD_007"),LocalizedString("Lang_RD_008"),LocalizedString("Lang_RD_015")], childVCs: [self.bookVC,self.backDepositVC,self.penaltyVC,self.doneVC], baseVC: self, delegate: self, showBorder: true)
    }
    
    private func callAPI() {
        switch pageMenuControl.getCurrentPage() {
        case 0:
            bookVC.callAPI()
            break
        case 1:
            backDepositVC.callAPI()
            break
        case 2:
            penaltyVC.callAPI()
            break
        case 3:
            doneVC.callAPI()
            break
        default: break
        }
    }
}

extension SiteOrderListMainViewController: ScrollPageMenuControlDelegate {
    
    func didSelectetPageAt(_ pageIndex: Int) {
        pageMenuControl.changeCurrentPage(pageIndex)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [unowned self] in
            self.callAPI()
        })
    }
}
