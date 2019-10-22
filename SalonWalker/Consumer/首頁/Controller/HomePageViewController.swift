//
//  HomePageViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/22.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import StoreKit

class HomePageViewController: BaseViewController {

    @IBOutlet private weak var topView: TopMenuView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private let pageMenuControl = ScrollPageMenuControl()
    private let fashionVC = UIStoryboard(name: kStory_HomePage, bundle: nil).instantiateViewController(withIdentifier: String(describing: FashionTrendViewController.self)) as! FashionTrendViewController
    private let popularVC = UIStoryboard(name: kStory_HomePage, bundle: nil).instantiateViewController(withIdentifier: String(describing: PopularRecommendViewController.self)) as! PopularRecommendViewController
    private let harborVC = UIStoryboard(name: kStory_HomePage, bundle: nil).instantiateViewController(withIdentifier: String(describing: HarborListViewController.self)) as! HarborListViewController
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        addObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageMenuControl.resizeFrame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Method
    override func networkDidRecover() {
        callAPI()
    }
    
    private func initialize() {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        pageMenuControl.setupPageViewWith(topView: topView, scrollView: scrollView, titles: [LocalizedString("Lang_HM_013"), LocalizedString("Lang_HM_014"), LocalizedString("Lang_HM_015")], childVCs: [fashionVC, popularVC, harborVC], baseVC: self, delegate: self, selectPageIndex:0)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUIAfterLoginout), name: NSNotification.Name(rawValue: kRefreshUIAfterLoginout), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUIAfterLoginout), name: NSNotification.Name(rawValue: kAPISyscode_501), object: nil)
    }
    
    @objc private func refreshUIAfterLoginout() {
        if pageMenuControl.getCurrentPage() == 2 {
            pageMenuControl.changeCurrentPage(0)
        }
    }
    
    // MARK: Event Handler
    @IBAction private func linkButtonPress(_ sender: UIButton) {
        let urlString = "morefunhouse://"
        if UIApplication.shared.canOpenURL(URL(string: urlString)!) {
            UIApplication.shared.openURL(URL(string: urlString)!)
        } else {
            guard let url = URL(string: "https://www.morefunhouse.com/wig_app") else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            /*
            apple退審 2019/01/29
            let vc = SKStoreProductViewController()
            vc.delegate = self
            
            self.showLoading()
            vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: "1054643458"]) { (result, error) in
                if error != nil {
                    SystemManager.showAlertWith(alertTitle: error?.localizedDescription, alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
                    self.hideLoading()
                } else {
                    self.present(vc, animated: true, completion: nil)
                    self.hideLoading()
                }
            }
            **/
        }
    }
    
    private func callAPI() {
        switch pageMenuControl.getCurrentPage() {
        case 0:
            fashionVC.callAPI()
            break
        case 1:
            popularVC.callAPI()
            break
        case 2:
            harborVC.callAPI()
            break
        default:break
        }
    }
}

extension HomePageViewController: ScrollPageMenuControlDelegate {
    
    func didSelectetPageAt(_ pageIndex: Int) {
        if !UserManager.isLoginSalonWalker() && pageIndex == 2 {
            SystemManager.showMustLoginAlert()
            pageMenuControl.changeCurrentPage(pageMenuControl.getLastPage())
        } else {
            pageMenuControl.changeCurrentPage(pageIndex)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [unowned self] in
                self.callAPI()
            })
        }
    }
}

extension HomePageViewController: SKStoreProductViewControllerDelegate {
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}
