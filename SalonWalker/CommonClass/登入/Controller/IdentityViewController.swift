//
//  IdentityViewController.swift
//  SalonWalker
//
//  Created by skywind on 2018/3/6.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class IdentityViewController: BaseViewController {

    private var registerType: LoginType = .general
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupButton()
    }
    
    func setupVCWithType(_ type: LoginType) {
        self.registerType = type
    }
    
    private func setupButton() {
        let upperValue: CGFloat = (SizeTool.isIphoneX()) ? 219 + 20 : 219
        let lowerValue: CGFloat = (SizeTool.isIphoneX()) ? 448 - 20 : 448
        let upperY = screenHeight / 667 * upperValue
        let lowerY = screenHeight / 667 * lowerValue
        
        let p1 = CGPoint(x: 0.0, y: 0.0)
        let p2 = CGPoint(x: 0.0, y: lowerY)
        let p3 = CGPoint(x: screenWidth, y: upperY)
        let p4 = CGPoint(x: screenWidth, y: 0.0)
        
        let p5 = CGPoint(x: 0.0, y: lowerY)
        let p6 = CGPoint(x: 0.0, y: screenHeight)
        let p7 = CGPoint(x: screenWidth, y: screenHeight)
        let p8 = CGPoint(x: screenWidth, y: upperY)

        let view1 = PolyView(frame: self.view.bounds, designerPoints: [p1,p2,p3,p4], providerPoints: [p5,p6,p7,p8], designerAction: { [unowned self] in
            UserManager.sharedInstance.userIdentity = .designer
            self.pushVC()
        }, providerAction: { [unowned self] in
            UserManager.sharedInstance.userIdentity = .store
            self.pushVC()
        })
        view.insertSubview(view1, at: 1)
    }
    
    private func pushVC() {
        if self.registerType == .general {
            let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SignInNameViewController") as! SignInNameViewController
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

