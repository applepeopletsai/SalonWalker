//
//  MyCustomerViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class MyCustomerViewController: BaseViewController {

    @IBOutlet private weak var tableView: MyCustomerListTableView!
    @IBOutlet private weak var statusButton: UIButton!
    @IBOutlet private weak var searchTextField: IBInspectableTextField!
    
    private var statusButtonType: StatusButtonType = .edit
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setupTableViewWith(type: statusButtonType, targetViewController: self, delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    // MARK: Method
    override func networkDidRecover() {
        callAPI()
    }
    
    private func callAPI() {
        tableView.callAPI()
    }
    
    // MARK: Event Handler
    @IBAction private func statusButtonClick(_ sender: UIButton) {
        switch statusButtonType {
        case .edit:
            statusButtonType = .cancel
            statusButton.setTitle(LocalizedString("Lang_GE_060"), for: .normal)
            tableView.changeType(type: statusButtonType)
            break
        case .cancel:
            statusButtonType = .edit
            statusButton.setTitle(LocalizedString("Lang_GE_058"), for: .normal)
            tableView.changeType(type: statusButtonType)
            break
        case .delete:
            tableView.deleteSelectCustomer()
            break
        default:
            break
        }
    }
}

extension MyCustomerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.tableView.callAPIWithKeyword(textField.text ?? "")
        return true
    }
}

extension MyCustomerViewController: MyCustomerListTableViewDelegate {
    
    func updateSelectCustomerIdArray(selectMIdArray: [Int]) {
        statusButton.setTitle((selectMIdArray.count > 0) ? LocalizedString("Lang_GE_059") : LocalizedString("Lang_GE_060"), for: .normal)
        statusButtonType = (selectMIdArray.count > 0) ? .delete : .cancel
    }
    
    func deleteCustomerSuccess() {
        statusButtonType = .cancel
        statusButton.setTitle(LocalizedString("Lang_GE_060"), for: .normal)
    }
    
    func didSelectCustomer(model: CustomerListModel.CustomerListInfo) {
        let vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: MyCustomerRecordViewController.self)) as! MyCustomerRecordViewController
        vc.setupVCWith(mId: model.mId, nickName: model.nickName, headerImgUrl: model.headerImgUrl)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

