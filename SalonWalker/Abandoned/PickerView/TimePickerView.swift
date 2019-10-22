//
//  TimePickerView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/22.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class TimePickerView: UIView {

    @IBOutlet private weak var pickerView: UIPickerView!
    
    private var timePickerView: UIView?
    private var timeItemArray: Array<String>?
    private var selectedIndex: Int?
    
    static func showTimePickerViewWith(timeItemArray: Array<String>?, selectedIndex: Int?) {
        let view = TimePickerView.init(timeItemArray: timeItemArray, selectedIndex: selectedIndex)
        SystemManager.topViewController().view.addSubview(view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(timeItemArray: Array<String>?, selectedIndex: Int?) {
        self.init(frame: CGRect.zero)
        self.timeItemArray = timeItemArray
        self.selectedIndex = selectedIndex
        setupPickerView()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        showTimePicker()
    }
    
    private func setupPickerView() {
        timePickerView = loadNib()
        var frame = self.bounds
        frame.size.height = frame.size.height * 0.3
        frame.origin.y = self.bounds.size.height
        timePickerView?.frame = frame
        timePickerView?.backgroundColor = .white
        timePickerView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        timePickerView?.layer.cornerRadius = 5.0
        if #available(iOS 11.0, *) {
            timePickerView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
            let path = UIBezierPath(roundedRect: timePickerView!.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 5.0, height: 5.0))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            timePickerView?.layer.mask = mask
        }
        addSubview(timePickerView!)
        self.alpha = 0.0
        self.backgroundColor = UIColor(white: 0, alpha: 0.8)
    }
    
    private func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    private func showTimePicker() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            if var timePickerViewFrame = self.timePickerView?.frame {
                timePickerViewFrame.origin.y = self.frame.size.height - timePickerViewFrame.size.height
                self.timePickerView?.frame = timePickerViewFrame
            }
            self.alpha = 1.0
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func dismissTimePicker() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            if var timePickerViewFrame = self.timePickerView?.frame {
                timePickerViewFrame.origin.y = self.frame.size.height
                self.timePickerView?.frame = timePickerViewFrame
            }
            self.alpha = 0.0
            self.layoutIfNeeded()
        }, completion: { (finished: Bool) in
            self.removeFromSuperview()
        })
    }
    
    @IBAction private func cancelButtonPress(_ sender: UIButton) {
        dismissTimePicker()
    }
    
    @IBAction private func confirmButtonPress(_ sender: UIButton) {
        dismissTimePicker()
    }

}
