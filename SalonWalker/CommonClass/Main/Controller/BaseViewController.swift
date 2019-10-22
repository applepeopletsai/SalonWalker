//
//  BaseViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/23.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol BaseViewControllerProtocol {
    func networkDidRecover()
    func applicationDidBecomeActive()
    func statusBarFrameChanged(_ frame: CGRect)
}

// StoryBoard - 業者端
let kStory_StoreHomePage = "StoreHomePage"
let kStory_StorePortfolio = "StorePortfolio"
let kStory_StoreAccount = "StoreAccount"
let kStory_StoreDetail = "StoreDetail"
let kStory_ReserveStore = "ReserveStore"

// StoryBoard - 消費者端
let kStory_HomePage = "HomePage"
let kStory_HairCut = "HairCut"
let kStory_Account = "Account"
let kStory_DesignerDetail = "DesignerDetail"
let kStory_ReserveDesigner = "ReserveDesigner"

// ViewController - 業者端
let kVC_StoreHomePage = "StoreHomePageViewController"
let kVC_StorePortfolio = "StorePortfolioViewController"
let kVC_StoreAccount = "StoreAccountViewController"

// ViewController - 消費者端
let kVC_HomePage = "HomePageViewController"
let kVC_HairCut = "HairCutViewController"
let kVC_Account = "AccountViewController"

class BaseViewController: UIViewController, BaseViewControllerProtocol {
    var gestureRecognizerShouldBegin = true
    var refreshControl = UIRefreshControl()
    
    private var refreshScrollView: UIScrollView?
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var originalPosition: CGPoint?
    
    lazy private var maskView: UIView = {
        let mask = UIView(frame: CGRect(origin: CGPoint.zero, size: screenSize))
        mask.backgroundColor = .white
        return mask
    }()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        addObserver()
        originalPosition = view.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Method
    func showLoading(text: String = "Loading...") {
        SystemManager.showLoadingWithText(text)
    }
    
    func hideLoading() {
        SystemManager.hideLoading()
    }
    
    func endLoadingWith<T: Codable>(model: BaseModel<T>?, handler: actionClosure? = nil) {
        SystemManager.endLoadingWith(model: model, handler: handler)
        removeMaskView()
    }
    
    func setupRefreshControlWith(scrollView: UIScrollView, action: Selector, target: Any) {
        refreshScrollView = scrollView
        refreshControl.addTarget(target, action: action, for: .valueChanged)
        refreshScrollView?.addSubview(refreshControl)
    }
    
    func addMaskView() {
        maskView.alpha = 1.0
        view.addSubview(maskView)
    }
    
    func removeMaskView() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.maskView.alpha = 0.0
        }) { (finished) in
            self.maskView.removeFromSuperview()
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNetworkDidRecover), name: Notification.Name(DidRecoverConnection), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleStatusBarFrameChanged(_:)), name: UIApplication.willChangeStatusBarFrameNotification, object: nil)
    }
    
    @objc private func handleNetworkDidRecover() {
        if type(of: SystemManager.topViewController()) == type(of: self) {
            networkDidRecover()
        }
    }
    
    @objc private func handleApplicationDidBecomeActive() {
        if type(of: SystemManager.topViewController()) == type(of: self) {
            applicationDidBecomeActive()
        }
    }
    
    @objc func handleStatusBarFrameChanged(_ notification: NSNotification) {
        if let userInfo = notification.userInfo, let statusBarFrame = userInfo["UIApplicationStatusBarFrameUserInfoKey"] as? CGRect, type(of: SystemManager.topViewController()) == type(of: self)  {
            statusBarFrameChanged(statusBarFrame)
        }
    }
    
    func addDismissGestureRecognizer() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGestureRecognizer!)
    }
    
    @objc private func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: view)
        var beginY: CGFloat = 0
        
        if panGesture.state == .began {
            beginY = translation.y
        } else if panGesture.state == .changed {
            if translation.y > 0 {
                view.frame.origin = CGPoint(x: translation.x, y: translation.y)
                let scale = 1 - (translation.y - beginY) / (screenHeight - beginY)
                view.alpha = scale
            }
        } else if panGesture.state == .ended {
            let velocity = panGesture.velocity(in: view)
            
            if velocity.y >= 1000, translation.y > 0 {
                UIView.animate(withDuration: 0.2, animations: {
                        self.view.frame.origin = CGPoint(x: self.view.frame.origin.x, y: self.view.frame.size.height)
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.center = self.originalPosition!
                    self.view.alpha = 1
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    // MARK: Event Handler
    @IBAction private func backButtonPress(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: BaseViewControllerProtocol
    func networkDidRecover() {}
    func applicationDidBecomeActive() {}
    func statusBarFrameChanged(_ frame: CGRect) {}
}

extension BaseViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if !gestureRecognizerShouldBegin {
            return false
        }
        guard let navi = self.navigationController else { return false }
        return navi.viewControllers.count > 1
    }
}

