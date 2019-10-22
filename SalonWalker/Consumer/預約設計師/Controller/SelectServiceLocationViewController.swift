//
//  SelectServiceLocationViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/13.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol SelectServiceLocationViewControllerDelegate: class {
    func didSelectStoreWith(model: SvcPlaceModel)
}

class SelectServiceLocationViewController: BaseViewController {

    @IBOutlet private weak var tableView: ServiceLocationTableView!
    @IBOutlet private weak var searchTextField: IBInspectableTextField!
    @IBOutlet private weak var confirmButton: IBInspectableButton!
    
    private var dId: Int?
    private var orderDate: String?
    private var startTime: String?
    private var svcTimeTotal: Int?
    private var selectSvcPlaceModel: SvcPlaceModel?
    private weak var delegate: SelectServiceLocationViewControllerDelegate?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.callAPI()
    }
    
    // MARK: Method
    override func networkDidRecover() {
        tableView.callAPI()
    }
    
    func setupVCWith(dId: Int, orderDate: String, startTime: String, svcTimeTotal: Int, delegate: SelectServiceLocationViewControllerDelegate?) {
        self.dId = dId
        self.orderDate = orderDate
        self.startTime = startTime
        self.svcTimeTotal = svcTimeTotal
        self.delegate = delegate
    }
    
    private func initialize() {
        tableView.setupTableViewWith(viewType: .ReserveDesigner, cellType: .edit, dId: dId!, orderDate: orderDate!, startTime: startTime!, svcTimeTotal: svcTimeTotal!, targetViewController: self, delegate: self)
    }
    
    // MARK: Event Handler
    @IBAction func confirmButtonClick(_ sender: UIButton) {
        guard let model = selectSvcPlaceModel else { return }
        self.delegate?.didSelectStoreWith(model: model)
        self.navigationController?.popViewController(animated: true)
    }
}

extension SelectServiceLocationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.tableView.callAPIWithKeyword(textField.text ?? "")
        return true
    }
}

extension SelectServiceLocationViewController: ServiceLocationTableViewDelegate {
    func didSelectSvcPlace(model: SvcPlaceModel) {
        self.selectSvcPlaceModel = model
        self.confirmButton.isEnabled = true
    }
    
    func updateSelectSvcPlaceIdArray(_ selectPIdArray: [Int]) {}
    
    func deleteSvcPlaceSuccess() {}
    
    func insertSvcPlaceSuccess() {}
}

