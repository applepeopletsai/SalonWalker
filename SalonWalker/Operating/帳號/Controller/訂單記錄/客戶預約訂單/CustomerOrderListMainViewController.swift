//
//  CustomerOrderListMainViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum OperatingOrderRecordType {
    // 客戶預約訂單
    case WaitForRespond     // 待回覆
    case GetDeposit         // 已收訂金
    case AlreadyCancel      // 已取消
    // 場地預約訂單
    case AlreadyBook        // 已預訂
    case BackDeposit        // 已退訂金
    case AlreadyPenalty     // 已罰款
    
    case AlreadyDone        // 已完成
}

/// 設計師：客戶預約訂單；場地：設計師預約訂單
class CustomerOrderListMainViewController: BaseViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var pageMenuView: TopMenuView!
    @IBOutlet private weak var naviTitleLabel: UILabel!
    
    private let pageMenuControl = ScrollPageMenuControl()
    private let waitForRespondVC = getVCWithListType(.WaitForRespond)
    private let getDepositVC = getVCWithListType(.GetDeposit)
    private let alreadyCancelVC = getVCWithListType(.AlreadyCancel)
    private let alreadyDoneVC = getVCWithListType(.AlreadyDone)
    private let alreadyBookVC = getVCWithListType(.AlreadyBook)
    
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
        if UserManager.sharedInstance.userIdentity == .designer {
            self.naviTitleLabel.text = LocalizedString("Lang_RD_002")
            self.pageMenuControl.setupPageViewWith(topView: self.pageMenuView, scrollView: self.scrollView, titles: [LocalizedString("Lang_RD_011"),LocalizedString("Lang_RD_012"),LocalizedString("Lang_RD_014"),LocalizedString("Lang_RD_015")], childVCs: [self.waitForRespondVC,self.getDepositVC,self.alreadyCancelVC,self.alreadyDoneVC], baseVC: self, delegate: self, showBorder: true)
        } else {
            self.naviTitleLabel.text = LocalizedString("Lang_RD_004")
            self.pageMenuControl.setupPageViewWith(topView: self.pageMenuView, scrollView: self.scrollView, titles: [LocalizedString("Lang_RD_013"),LocalizedString("Lang_RD_014"),LocalizedString("Lang_RD_015")], childVCs: [self.alreadyBookVC,self.alreadyCancelVC,self.alreadyDoneVC], baseVC: self, delegate: self, showBorder: true)
        }
    }
    
    private static func getVCWithListType(_ type: OperatingOrderRecordType) -> CustomerOrderListViewController {
        let vc = UIStoryboard(name: "OrderRecord", bundle: nil).instantiateViewController(withIdentifier: String(describing: CustomerOrderListViewController.self)) as! CustomerOrderListViewController
        vc.setupVCWithListType(type)
        return vc
    }
    
    private func callAPI() {
        if UserManager.sharedInstance.userIdentity == .designer {
            switch pageMenuControl.getCurrentPage() {
            case 0:
                waitForRespondVC.callAPI()
                break
            case 1:
                getDepositVC.callAPI()
                break
            case 2:
                alreadyCancelVC.callAPI()
                break
            case 3:
                alreadyDoneVC.callAPI()
                break
            default: break
            }
        } else {
            switch pageMenuControl.getCurrentPage() {
            case 0:
                alreadyBookVC.callAPI()
                break
            case 1:
                alreadyCancelVC.callAPI()
                break
            case 2:
                alreadyDoneVC.callAPI()
                break
            default: break
            }
        }
    }
}

extension CustomerOrderListMainViewController: ScrollPageMenuControlDelegate {
    func didSelectetPageAt(_ pageIndex: Int) {
        pageMenuControl.changeCurrentPage(pageIndex)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [unowned self] in
            self.callAPI()
        })
    }
}
