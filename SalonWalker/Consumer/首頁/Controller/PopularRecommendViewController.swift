//
//  PopularRecommendViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/23.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class PopularRecommendViewController: BaseViewController {

    @IBOutlet private weak var tableView: DesignerInfoTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addMaskView()
        self.setupTableView()
    }
    
    // MARK: Method
    func callAPI() {
        tableView.callAPI()
    }
    
    private func setupTableView() {
        self.tableView.setupTableViewWith(targetViewController: self, tableViewType: .PopularRecommend)
    }
}

