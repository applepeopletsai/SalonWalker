//
//  PayDepositViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/16.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class PayDepositViewController: BaseViewController {

    @IBOutlet private weak var tableView: OrderRecordTableView!
    @IBOutlet private var buttons: [UIButton]!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.setupTableViewWith(targetViewController: self)
    }

    // MARK: Method
    func callAPI() {
        // tag0: 待回覆, tag1: 已確定
        if let selectTag = (buttons.filter{ $0.isSelected }.map{ $0.tag }.first) {
            let type: ConsumerOrderRecordType = (selectTag == 0) ? .PayDeposit_Wait : .PayDeposit_Confirm
            self.tableView.callAPIWithType(type)
        }
    }
    
    // MARK: Event Handler
    @IBAction private func typeButtonPress(_ sender: UIButton) {
        self.buttons.forEach { (button) in
            button.isSelected = (sender.tag == button.tag)
            button.backgroundColor = (sender.tag == button.tag) ? color_1A1C69 : color_EEE9FE
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
            self.tableView.resetDataWithType((sender.tag == 0) ? .PayDeposit_Wait : .PayDeposit_Confirm)
        })
    }
}


