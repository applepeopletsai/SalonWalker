//
//  YearMonthPickerViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/20.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

typealias yearMonthPickerConfirmHandler = (_ month: Int, _ year: Int) -> Void

class YearMonthPickerViewController: BaseViewController {
    
    @IBOutlet private weak var yearMonthPicker: YearMonthPicker!
    
    private var cancelAction: actionClosure?
    private var confirmAction: yearMonthPickerConfirmHandler?
    
    private var selectMonth: Int?
    private var selectYear: Int?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.yearMonthPicker.yearMonthPickerDelegate = self
        self.selectYear = self.yearMonthPicker.currentYear
        self.selectMonth = self.yearMonthPicker.currentMonth
    }

    // MARK: Method
    func setupVcWith(cancelAction: actionClosure?, confirmAction: @escaping yearMonthPickerConfirmHandler) {
        self.cancelAction = cancelAction
        self.confirmAction = confirmAction
    }
    
    // MARK: Event Handler
    @IBAction private func cancelButtonPress(_ sender: UIButton) {
        cancelAction?()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func confirmButtonPress(_ sender: UIButton) {
        if let month = selectMonth, let yaer = selectYear {
            confirmAction?(month, yaer)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension YearMonthPickerViewController: YearMonthPickerDelegate {
    func didSelectItem(month: Int, year: Int) {
        self.selectMonth = month
        self.selectYear = year
    }
}
