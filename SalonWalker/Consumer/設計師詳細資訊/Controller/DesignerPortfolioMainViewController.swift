//
//  DesignerPortfolioMainViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/14.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class DesignerPortfolioMainViewController: BaseViewController {

    @IBOutlet private weak var topMenuView: TopMenuView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private let personalPortfolioVC = UIStoryboard(name: kStory_DesignerDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: DesignerPortfolioViewController.self)) as! DesignerPortfolioViewController
    private let worksPortfolioVC = UIStoryboard(name: kStory_DesignerDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: DesignerPortfolioViewController.self)) as! DesignerPortfolioViewController
    private var pageMenuControl = ScrollPageMenuControl()
    
    private var portfolioType: PortfolioType = .Personal
    private var ouId = 0
    
    // MARK: Life cycle
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
    
    func setupVCWith(ouId: Int, portfolioType: PortfolioType) {
        self.ouId = ouId
        self.portfolioType = portfolioType
    }
    
    private func initialize() {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        personalPortfolioVC.setupVCWith(portfolioType: .Personal, ouId: ouId)
        worksPortfolioVC.setupVCWith(portfolioType: .WorkShop, ouId: ouId)
        
        pageMenuControl.setupPageViewWith(topView: topMenuView, scrollView: scrollView, titles: [LocalizedString("Lang_DD_009"),LocalizedString("Lang_DD_010")], childVCs: [personalPortfolioVC,worksPortfolioVC], baseVC: self, delegate: self, showBorder: true)
        
        if portfolioType == .WorkShop {
            pageMenuControl.changeCurrentPage(1)
        }
    }
    
    private func callAPI() {
        switch pageMenuControl.getCurrentPage() {
        case 0:
            worksPortfolioVC.cleanData()
            personalPortfolioVC.callAPI()
            break
        case 1:
            personalPortfolioVC.cleanData()
            worksPortfolioVC.callAPI()
            break
        default:break
        }
    }
}

extension DesignerPortfolioMainViewController: ScrollPageMenuControlDelegate {
    func didSelectetPageAt(_ pageIndex: Int) {
        pageMenuControl.changeCurrentPage(pageIndex)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
            self.callAPI()
        }
    }
}


