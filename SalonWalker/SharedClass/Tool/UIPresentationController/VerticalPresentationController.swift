//
//  VerticalPresentationController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/27.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class VerticalPresentationController: UIPresentationController {

    // MARK: Property
    private var bgView: UIVisualEffectView?
    fileprivate let presentationVC = PresentationVerticalPanAnimationController()
    
    // MAKR: Method
    func present(height: CGFloat) {
        let width = screenWidth
        presentedViewController.preferredContentSize = CGSize(width: width, height: height)
        presentedViewController.transitioningDelegate = self
        presentingViewController.present(presentedViewController, animated: true, completion: nil)
    }
    
    // MARK: Override Function
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        presentedViewController.modalPresentationStyle = .custom
    }
    
    override var presentedView: UIView? {
        let pView = presentedViewController.view
        pView?.layer.cornerRadius = 10.0
        return pView
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        bgView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        bgView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tap(gestureRecognizer:))))
        
        containerView?.addSubview(bgView!)
        containerView?.addSubview(presentedView!)
        
        bgView?.alpha = 0.0
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
            self.bgView?.alpha = 0.7
        }, completion: nil)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        
        // The value of the 'completed' argument is the same value passed to the
        // -completeTransition: method by the animator.  It may
        // be NO in the case of a cancelled interactive transition.
        if (completed == false)
        {
            // The system removes the presented view controller's view from its
            // superview and disposes of the containerView.  This implicitly
            // removes the views created in -presentationTransitionWillBegin: from
            // the view hierarchy.  However, we still need to relinquish our strong
            // references to those view.
            bgView = nil
        }
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { (content) in
            self.bgView?.alpha = 0.0
        }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        
        // The value of the 'completed' argument is the same value passed to the
        // -completeTransition: method by the animator.  It may
        // be NO in the case of a cancelled interactive transition.
        if (completed == true)
        {
            // The system removes the presented view controller's view from its
            // superview and disposes of the containerView.  This implicitly
            // removes the views created in -presentationTransitionWillBegin: from
            // the view hierarchy.  However, we still need to relinquish our strong
            // references to those view.
            bgView = nil;
        }
    }
    
    // MARK: Layout
    
    // This method is invoked whenever the presentedViewController's
    // preferredContentSize property changes.  It is also invoked just before the
    // presentation transition begins (prior to -presentationTransitionWillBegin).
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if presentedViewController == container as? UIViewController {
            containerView?.setNeedsLayout()
        }
    }
    
    // When the presentation controller receives a
    // -viewWillTransitionToSize:withTransitionCoordinator: message it calls this
    // method to retrieve the new size for the presentedViewController's view.
    // The presentation controller then sends a
    // -viewWillTransitionToSize:withTransitionCoordinator: message to the
    // presentedViewController with this size as the first argument.
    
    // Note that it is up to the presentation controller to adjust the frame
    // of the presented view controller's view to match this promised size.
    // We do this in -containerViewWillLayoutSubviews.
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if presentedViewController == container as? UIViewController {
            return container.preferredContentSize
        } else {
            return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let containerViewRect = (containerView?.bounds)!
        let presentedViewControllerContentSize = size(forChildContentContainer:presentedViewController, withParentContainerSize: containerViewRect.size)
        
        return CGRect(x: containerViewRect.origin.x,
                      y: containerViewRect.maxY - presentedViewControllerContentSize.height,
                      width: containerViewRect.width,
                      height: presentedViewControllerContentSize.height)
    }
    
    
    // This method is similar to the -viewWillLayoutSubviews method in
    // UIViewController.  It allows the presentation controller to alter the
    // layout of any custom views it manages.
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        bgView?.frame = (containerView?.bounds)!
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    // MARK: GestureRecognizer
    @objc func tap(gestureRecognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}

extension VerticalPresentationController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentationVC
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentationVC
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return self
    }
}
