//
//  NotPurchaseViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol NotPurchaseViewControllerDelegate: class {
    func didSelectPaymentTypeWith(model: LongLeasePricesModel, purchase: Bool)
}

class NotPurchaseViewController: BaseViewController {
    
    @IBOutlet private weak var tableView: PaySchemeTableView!
    
    private var dataArray = [LongLeasePricesModel]()
    private var showSchemeType: ShowPaySchemeType = .check
    private var chooseSchemeType: PaySchemeType = .longRent
    private weak var delegate: NotPurchaseViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    func setupVCWith(dataArray: [LongLeasePricesModel], showSchemeType: ShowPaySchemeType, chooseSchemeType: PaySchemeType, delegate: NotPurchaseViewControllerDelegate) {
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

extension NotPurchaseViewController: PaySchemeTableViewDelegate {
    func didSelectPaymentTypeWithModel(_ model: Codable) {
        if let model = model as? LongLeasePricesModel {
            self.delegate?.didSelectPaymentTypeWith(model: model, purchase: false)
        }
    }
}
