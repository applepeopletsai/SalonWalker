//
//  HarborListViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/23.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class HarborListViewController: BaseViewController {

    @IBOutlet private weak var tableView: DesignerInfoTableView!
    @IBOutlet private weak var navigationViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var navigationView: IBInspectableView!
    private var showNavigation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
        setupNavigation()
        setupTableView()
    }
    
    // MARK: Method
    override func networkDidRecover() {
        callAPI()
    }
    
    func showNavigation(_ show: Bool) {
        self.showNavigation = show
    }
    
    func callAPI() {
        tableView.callAPI()
    }
    
    private func setupTableView() {
        self.tableView.setupTableViewWith(targetViewController: self, tableViewType: .HarborList)
    }
    
    private func setupNavigation() {
        if showNavigation {
            self.navigationViewHeight.constant = 44.0
            self.navigationView.clipsToBounds = false
        }
    }
}
