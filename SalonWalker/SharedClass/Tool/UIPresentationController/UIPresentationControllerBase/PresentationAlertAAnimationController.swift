//
//  PresentationAlertAAnimationController.swift
//  ImaageAlert
//
//  Created by skywind on 2018/2/26.
//  Copyright © 2018年 Jimmy. All rights reserved.
//

import UIKit

class PresentationAlertAnimationController: BaseAnimationController {
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController, toVC: UIViewController, fromView: UIView, toView: UIView) {
        // fromVc 總是獲取到正在顯示在螢幕上的Controller
        let isPresenting = toVC.presentingViewController == fromVC
        if isPresenting {
            toView.alpha = 0.0
            toView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                toView.transform = CGAffineTransform.identity
                toView.alpha = 1.0
            }, completion: { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        } else {
            fromView.alpha = 1.0
            fromView.transform = CGAffineTransform.identity
            UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                fromView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                fromView.alpha = 0.0
            }, completion: { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}
