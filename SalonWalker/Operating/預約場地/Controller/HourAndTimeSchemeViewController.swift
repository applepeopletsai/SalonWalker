//
//  HourAndTimeSchemeViewController.swift
//  SalonWalker
//
//  Created by Scott.Tsai on 2018/4/28.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol HourAndTimeSchemeViewControllerDelegate: class {
    func confirmButtonPressWith(model: Codable, type: PaySchemeType)
}

class HourAndTimeSchemeViewController: BaseViewController {
  
    @IBOutlet private weak var tableView: PaySchemeTableView!
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var confirmButton: IBInspectableButton!
    
    private var dataArray: [HoursAndTimesPricesModel]?
    private var showSchemeType: ShowPaySchemeType = .check
    private var chooseSchemeType: PaySchemeType = .hour
    private var selectModel: Codable?
    
    private weak var delegate: HourAndTimeSchemeViewControllerDelegate?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    // MARK: Method
    func setupVCWith(dataArray: [HoursAndTimesPricesModel]?, showSchemeType: ShowPaySchemeType, chooseSchemeType: PaySchemeType, delegate: HourAndTimeSchemeViewControllerDelegate) {
        self.dataArray = dataArray
        self.showSchemeType = showSchemeType
        self.chooseSchemeType = chooseSchemeType
        self.delegate = delegate
    }
    
    private func initialize() {
        topLabel.text = (chooseSchemeType == .hour) ? LocalizedString("Lang_PS_002") : LocalizedString("Lang_PS_003")
        confirmButton.isHidden = (showSchemeType == .check)
        
        tableView.setupTableViewWith(hourAndTimePriceArray: dataArray, longLeasePriceArray: nil, showSchemeType: showSchemeType, chooseSchemeType: chooseSchemeType, delegate: self)
    }
    
    @IBAction private func disMissButtonClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func confirmButtonClick(_ sender: UIButton) {
        if let model = selectModel {
            self.delegate?.confirmButtonPressWith(model: model, type: chooseSchemeType)
        }
        dismiss(animated: true, completion: nil)
    }
}

extension HourAndTimeSchemeViewController: PaySchemeTableViewDelegate {
    func didSelectPaymentTypeWithModel(_ model: Codable) {
        selectModel = model
        confirmButton.isEnabled = true
    }
}

