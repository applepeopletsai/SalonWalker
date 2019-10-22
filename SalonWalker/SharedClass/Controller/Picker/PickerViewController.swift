//
//  PickerViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/27.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

typealias pickerConfirmHandler = (_ item: String, _ selectIndex: Int) -> Void

class PickerViewController: UIViewController {

    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var hintTitleLabel: UILabel!
    
    private var itemArray: Array<String>?
    private var selectedIndex: Int = 0
    private var hintTitle: String?
    
    private var cancelAction: actionClosure?
    private var confirmAction: pickerConfirmHandler?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hintTitleLabel.text = hintTitle
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pickerView.selectRow(selectedIndex, inComponent: 0, animated: true)
    }
    
    // MARK: Method
    func setupVCWith(itemArray: Array<String>?, selectedIndex: Int, hintTitle: String? = nil, cancelAction: actionClosure?, confirmAction: @escaping pickerConfirmHandler) {
        self.itemArray = itemArray
        self.selectedIndex = selectedIndex
        self.hintTitle = hintTitle
        self.cancelAction = cancelAction
        self.confirmAction = confirmAction
    }
    
    // MARK: Event Handler
    @IBAction private func cancelButtonPress(_ sender: UIButton) {
        cancelAction?()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func confirmButtonPress(_ sender: UIButton) {
        if let itemArray = itemArray, itemArray.count > 0, let confirmAction = confirmAction {
            confirmAction(itemArray[selectedIndex], selectedIndex)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension PickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let itemArray = itemArray {
            return itemArray.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let itemArray = itemArray {
            return itemArray[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 38.0
    }
}
