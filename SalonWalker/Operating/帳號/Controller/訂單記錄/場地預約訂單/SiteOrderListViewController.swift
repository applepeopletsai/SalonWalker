//
//  SiteOrderListViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/22.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class SiteOrderListViewController: BaseViewController {

    @IBOutlet private weak var tableView: SiteReservationTableView!
    
    private var type: OperatingOrderRecordType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.setupTableViewWith(type: type ?? .AlreadyBook, targetViewController: self)
    }
    
    func setupVCWithListType(_ type: OperatingOrderRecordType) {
        self.type = type
    }

    func callAPI() {
        tableView.callAPI()
    }
}
