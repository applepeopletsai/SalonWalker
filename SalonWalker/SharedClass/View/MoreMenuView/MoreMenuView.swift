//
//  MoreMenuView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/12/21.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol MoreMenuViewDelegate: class {
    func allRead()
    func allDelete()
}

class MoreMenuView: UIView {

    private weak var delegate: MoreMenuViewDelegate?
    
    static func initWith(frame: CGRect, delegate: MoreMenuViewDelegate?) -> MoreMenuView? {
        guard let view = Bundle.main.loadNibNamed("MoreMenuView", owner: nil, options: nil)?.first as? MoreMenuView else {
            return nil
        }
        view.frame = frame
        view.alpha = 0
        view.delegate = delegate
        return view
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.layoutIfNeeded()
        if self.superview != nil { // Did Add Self To Superview
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.alpha = 1
                self?.layoutIfNeeded()
            }
        }
    }
    
    override func removeFromSuperview() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.alpha = 0
            self?.layoutIfNeeded()
        }) { [weak self] (finish) in
            if finish {
                self?.superRemoveFromSuperview()
            }
        }
    }
    
    private func superRemoveFromSuperview() {
        super.removeFromSuperview()
    }
    
    @IBAction private func allReadButtonPress(_ sender: UIButton) {
        delegate?.allRead()
    }
    
    @IBAction private func allDeleteButtonPress(_ sender: UIButton) {
        delegate?.allDelete()
    }
}
