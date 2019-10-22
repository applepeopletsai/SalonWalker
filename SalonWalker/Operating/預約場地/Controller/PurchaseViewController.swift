//
//  PurchaseViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol PurchaseViewControllerDelegate: class {
    func didSelectPaymentTypeWith(model: LongLeasePricesModel, purchase: Bool)
}

class PurchaseViewController: BaseViewController {
   
    @IBOutlet private weak var tableView: PaySchemeTableView!
    
    private var dataArray = [LongLeasePricesModel]()
    private var showSchemeType: ShowPaySchemeType = .check
    private var chooseSchemeType: PaySchemeType = .longRent
    private weak var delegate: PurchaseViewControllerDelegate?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    // MARK: Method
    func setupVCWith(dataArray: [LongLeasePricesModel], showSchemeType: ShowPaySchemeType, chooseSchemeType: PaySchemeType, delegate: PurchaseViewControllerDelegate) {
        self.dataArray = dataArray
        self.showSchemeType = showSchemeType
        self.chooseSchemeType = chooseSchemeType
        self.delegate = delegate
    }
    
    func resetSelectStatus() {
        tableView.resetSelectStatus()
    }
    
    private func initialize() {
        tableView.setupTableViewWith(hourAndTimePriceArray: nil, longLeasePriceArray: dataArray, showSchemeType: showSchemeType, chooseSchemeType: chooseSchemeType, delegate: self)
    }
}

extension PurchaseViewController: PaySchemeTableViewDelegate {
    func didSelectPaymentTypeWithModel(_ model: Codable) {
        if let model = model as? LongLeasePricesModel {
            self.delegate?.didSelectPaymentTypeWith(model: model, purchase: true)
        }
    }
}
