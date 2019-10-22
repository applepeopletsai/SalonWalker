//
//  ShowTableViewController.swift
//  SalonWalker
//
//  Created by Scott.Tsai on 2018/5/16.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

typealias shareTableViewConfirmHandler = (_ selectIndexs: [Int]) -> Void

class ShareTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var itemArray: [String]?
    private var selectIndexArray = [Int]()
    private var confirmAction: shareTableViewConfirmHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func confirmButtonClick(_ sender: UIButton) {
        confirmAction?(selectIndexArray.sorted())
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupVCWith(itemArray: [String], selectIndexArray: [Int], confirmAction: @escaping shareTableViewConfirmHandler) {
        self.itemArray = itemArray
        self.selectIndexArray = selectIndexArray
        self.confirmAction = confirmAction
    }
}

extension ShareTableViewController: UITableViewDelegate ,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShareTableViewCell", for: indexPath) as! ShareTableViewCell
        if let itemArray = self.itemArray {
            cell.setupCellWith(itemString: itemArray[indexPath.row], isSelect: (selectIndexArray.index(of: indexPath.row) != nil))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = selectIndexArray.index(of: indexPath.row) {
            self.selectIndexArray.remove(at: index)
        } else {
            self.selectIndexArray.append(indexPath.row)
        }
        self.tableView.reloadData()
    }
}
