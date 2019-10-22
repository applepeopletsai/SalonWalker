//
//  SignInOutView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/27.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol SignInOutViewDelegate: class {
    func gpsButtonPress()
    func qrcodeButtonPress()
}

class SignInOutView: UIView {

    private weak var delegate: SignInOutViewDelegate?
    
    static func getView(with delegate: SignInOutViewDelegate?) -> SignInOutView? {
        guard let view = Bundle.main.loadNibNamed(String(describing: SignInOutView.self), owner: self, options: nil)?.first as? SignInOutView else {
            return nil
        }
        view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        view.alpha = 0
        view.delegate = delegate
        return view
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.alpha = 1
        })
    }
    
    override func removeFromSuperview() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.alpha = 0
        }, completion: { [weak self] (finish) in
            if finish {
                self?.superRemoveFromSuperview()
            }
        })
    }
    
    private func superRemoveFromSuperview() {
        super.removeFromSuperview()
    }
    
    @IBAction private func gpsButtonPress(_ sender: UIButton) {
        self.delegate?.gpsButtonPress()
        self.removeFromSuperview()
    }
    
    @IBAction private func qrcodeButtonPress(_ sender: UIButton) {
        self.delegate?.qrcodeButtonPress()
        self.removeFromSuperview()
    }
    
    @IBAction private func cancelButtonPress(_ sender: UIButton) {
        self.removeFromSuperview()
    }
}
