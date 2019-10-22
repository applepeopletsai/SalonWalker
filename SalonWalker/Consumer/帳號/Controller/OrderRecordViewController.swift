//
//  OrderRecordViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/16.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum ConsumerOrderRecordType {
    case PayDeposit_Wait, PayDeposit_Confirm, BackDeposit, Penalty, Finish
}

class OrderRecordViewController: BaseViewController {

    @IBOutlet private weak var topView: TopMenuView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private let pageMenuControl = ScrollPageMenuControl()
    private let payDepositVC = UIStoryboard(name: kStory_Account, bundle: nil).instantiateViewController(withIdentifier: String(describing: PayDepositViewController.self)) as! PayDepositViewController
    private let backDepositVC = UIStoryboard(name: kStory_Account, bundle: nil).instantiateViewController(withIdentifier: String(describing: BackDepositViewController.self)) as! BackDepositViewController
    private let penaltyVC = UIStoryboard(name: kStory_Account, bundle: nil).instantiateViewController(withIdentifier: String(describing: PenaltyViewController.self)) as! PenaltyViewController
    private let finishVC = UIStoryboard(name: kStory_Account, bundle: nil).instantiateViewController(withIdentifier: String(describing: FinishViewController.self)) as! FinishViewController
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageMenuControl.resizeFrame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    // MARK: Method
    override func networkDidRecover() {
        callAPI()
    }
    
    private func initialize() {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        pageMenuControl.setupPageViewWith(topView: topView, scrollView: scrollView, titles: [LocalizedString("Lang_RD_006"), LocalizedString("Lang_RD_007"), LocalizedString("Lang_RD_008"), LocalizedString("Lang_RD_015")], childVCs: [payDepositVC, backDepositVC, penaltyVC, finishVC], baseVC: self, delegate: self, showBorder: true)
    }
    
    private func callAPI() {
        switch pageMenuControl.getCurrentPage() {
        case 0:
            payDepositVC.callAPI()
            break
        case 1:
            backDepositVC.callAPI()
            break
        case 2:
            penaltyVC.callAPI()
            break
        case 3:
            finishVC.callAPI()
            break
        default: break
        }
    }
}

extension OrderRecordViewController: ScrollPageMenuControlDelegate {
    
    func didSelectetPageAt(_ pageIndex: Int) {
        pageMenuControl.changeCurrentPage(pageIndex)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [unowned self] in
            self.callAPI()
        })
    }
}
