//
//  AddServiceLocationViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/27.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

let kRecallApiGetSetSvcPlace = "RecallApiGetSetSvcPlace"

class AddServiceLocationViewController: BaseViewController {

    @IBOutlet weak private var tableView: ServiceLocationTableView!
    @IBOutlet weak private var searchTextField: IBInspectableTextField!
    @IBOutlet weak private var confirmButton: IBInspectableButton!

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setupTableViewWith(viewType: .AddServiceLocation, cellType: .edit, targetViewController: self, delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.callAPI()
    }

    // Method
    override func networkDidRecover() {
        tableView.callAPI()
    }
    
    // MARK: Event Handler
    @IBAction func dismissButtonClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func confirmButtonClick(_ sender: UIButton) {
        self.tableView.insertSelectSvcPlace()
    }
}

extension AddServiceLocationViewController: ServiceLocationTableViewDelegate {
    func updateSelectSvcPlaceIdArray(_ selectPIdArray: [Int]) {
        self.confirmButton.isEnabled = (selectPIdArray.count != 0)
    }
    
    func insertSvcPlaceSuccess() {
        self.confirmButton.isEnabled = false
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRecallApiGetSetSvcPlace), object: nil)
        })
    }
    
    func deleteSvcPlaceSuccess() {}
    
    func didSelectSvcPlace(model: SvcPlaceModel) {}
}

extension AddServiceLocationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.tableView.callAPIWithKeyword(textField.text ?? "")
        return true
    }
}
