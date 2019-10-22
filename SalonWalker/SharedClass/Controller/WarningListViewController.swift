//
//  WarningListViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/12/19.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum WarningListType {
    case caution, miss
}

class WarningListViewController: BaseViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private var type: WarningListType = .caution
    private var data = [WarningDetailModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = (type == .caution) ? LocalizedString("Lang_AC_004") : LocalizedString("Lang_AC_002")
        self.tableView.tableFooterView = UIView()
    }
    
    func setupVCWith(data: [WarningDetailModel], type: WarningListType) {
        self.data = data
        self.type = type
    }
}

extension WarningListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WarningListCell.self), for: indexPath) as! WarningListCell
        cell.setupCellWith(model: data[indexPath.row], type: type)
        return cell
    }
}

extension WarningListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (type == .caution) ? 75 : 50
    }
}
