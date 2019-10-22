//
//  OneButtonAlertView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/22.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class OneButtonAlertView: UIView {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!
    
    private var buttonAction: actionClosure?
    private var alertViewFrame: CGRect = CGRect.zero
    private var alertMessage: String = ""
    private var image: UIImage?
    private var buttonTitle: String = ""
    
    static func showOneButtonAlertViewWith(height: CGFloat, alertMessage: String, image: UIImage?, buttonTitle: String, buttonAction:actionClosure?) {
        let view = OneButtonAlertView.init(height: height, alertMessage: alertMessage, image: image, buttonTitle: buttonTitle, buttonAction: buttonAction)
        SystemManager.topViewController().view.addSubview(view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(height: CGFloat, alertMessage: String, image: UIImage?, buttonTitle: String, buttonAction:actionClosure?) {
        self.init(frame: CGRect.zero)
        let width = screenWidth - 10.0 * 2
        let x = (screenWidth - width) * 0.5
        let y = (screenHeight - height) * 0.5
        self.alertViewFrame = CGRect(x: x, y: y, width: width, height: height)
        self.alertMessage = alertMessage
        self.image = image
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
        setupAlertView()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
            self.alpha = 1.0
        }, completion: nil)
    }
    
    private func setupAlertView() {
        let view = loadNib()
        view.frame = alertViewFrame
        view.backgroundColor = .white
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.layer.cornerRadius = 5.0
        addSubview(view)
        self.alpha = 0.0
        self.backgroundColor = UIColor(white: 0, alpha: 0.8)
        imageView.image = image
        messageLabel.text = alertMessage
        actionButton.setTitle(buttonTitle, for: .normal)
    }
    
    private func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    @IBAction private func buttonPress(_ sender: UIButton) {
        buttonAction?()
        self.removeFromSuperview()
    }
}
