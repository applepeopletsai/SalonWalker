//
//  ExtensionUINavigationController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/6/25.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

extension UINavigationController {
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: actionClosure?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    func popViewController(animated: Bool, completion: actionClosure?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
    }
    
    func popToRootViewController(animated: Bool, completion: actionClosure?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popToRootViewController(animated: animated)
        CATransaction.commit()
    }
}
