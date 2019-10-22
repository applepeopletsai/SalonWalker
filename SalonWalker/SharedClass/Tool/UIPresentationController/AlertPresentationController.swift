//
//  AlertPresentationController.swift
//  CustomTransitionsDemo
//
//  Created by Jimmy on 2018/02/22.
//

import UIKit

class AlertPresentationController: UIPresentationController {
    
    // MARK: Property
    private var bgView: UIVisualEffectView?
    private var needDismissGesture = true
    private var completionHandler: actionClosure?
    fileprivate let presentationAC = PresentationAlertAnimationController()
    
    // MAKR: Method
    func present(height: CGFloat, autoDismiss: Bool? = nil, needDismissGesture: Bool? = nil, autoDismissCompletion: actionClosure? = nil) {
        if let needDismissGesture = needDismissGesture {
            self.needDismissGesture = needDismissGesture
        }
        self.completionHandler = autoDismissCompletion
        let width = screenWidth - 10.0 * 2
        var h = height
        if h > screenHeight - 20.0 * 2 {
            h = screenHeight - 20.0 * 2
        }
        presentedViewController.preferredContentSize = CGSize(width: width, height: h)
        presentedViewController.transitioningDelegate = self
        presentingViewController.present(presentedViewController, animated: true, completion: nil)
        if let autoDismiss = autoDismiss, autoDismiss == true {
            let presented = presentingViewController.presentedViewController
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                if self.presentingViewController.presentedViewController == presented {
                    self.dismiss()
                }
            })
        }
    }
    
    private func dismiss() {
        presentingViewController.dismiss(animated: true, completion: completionHandler)
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
        if needDismissGesture {
            bgView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tap(gestureRecognizer:))))
        }
        
        // https://stackoverflow.com/questions/5432995/interaction-beyond-bounds-of-uiview
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
            bgView = nil
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
        
        return CGRect(x: (containerViewRect.width - presentedViewControllerContentSize.width) / 2.0,
                      y: (containerViewRect.height - presentedViewControllerContentSize.height) / 2.0,
                      width: presentedViewControllerContentSize.width,
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
    @objc private func tap(gestureRecognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true, completion: completionHandler)
    }
}

extension AlertPresentationController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentationAC
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentationAC
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
