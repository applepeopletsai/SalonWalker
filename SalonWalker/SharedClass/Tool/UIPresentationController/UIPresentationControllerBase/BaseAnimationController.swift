//
//  BaseAnimationController.swift
//  CustomTransitionsDemo
//
//  Created by Jimmy on 2018/02/22.
//

import UIKit

class BaseAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: Property
    var reverse: Bool = false
    var duration: TimeInterval {
        return 0.25
    }
    
    // MARK: Override Function
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController, toVC: UIViewController, fromView: UIView, toView: UIView) {
        fatalError("You must override \(#function) in a subclass")
    }
    
    // MARK UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let fromView = fromVC.view // transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = toVC.view // transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        animateTransition(using: transitionContext, fromVC: fromVC, toVC: toVC, fromView: fromView!, toView: toView!)
    }
}
