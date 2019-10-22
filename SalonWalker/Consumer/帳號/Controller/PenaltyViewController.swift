//
//  PenaltyViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/16.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class PenaltyViewController: BaseViewController {

    @IBOutlet private weak var tableView: OrderRecordTableView!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.setupTableViewWith(targetViewController: self)
    }
    
    // MARK: Method
    func callAPI() {
        self.tableView.callAPIWithType(.Penalty)
    }

}
