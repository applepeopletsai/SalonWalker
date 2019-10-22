//
//  ServiceLocationViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol ServiceLocationViewControllerDelegate: class {
    func changeNaviRightButtonTitleWith(selectSvcPlaceCount: Int)
}

class ServiceLocationViewController: BaseViewController {

    @IBOutlet private weak var tableView: ServiceLocationTableView!
    @IBOutlet private weak var searchTextField: IBInspectableTextField!
    @IBOutlet private weak var addLocationViewHeight: NSLayoutConstraint!

    weak var serviceLocationVCDelegate: ServiceLocationViewControllerDelegate?
  
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setupTableViewWith(viewType: .SetServiceLocation, cellType: .normal, targetViewController: self, delegate: self)
        addLocationViewHeight.constant = 0
        addObser()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Method
    func naviRightButtonClick(naviRightButtonType: StatusButtonType) {
        UIView.animate(withDuration: 0.3) {
            switch naviRightButtonType {
            case .edit:
                self.addLocationViewHeight.constant = 40
                self.tableView.changeType(cellType: .edit)
            case .cancel:
                self.addLocationViewHeight.constant = 0
                self.tableView.changeType(cellType: .normal)
            case .delete:
                self.tableView.deleteSelectSvcPlace()
                break
            default:
                break
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func callAPI() {
        tableView.callAPI()
    }
    
    private func addObser() {
        NotificationCenter.default.addObserver(self, selector: #selector(recallAPI), name: NSNotification.Name(rawValue: kRecallApiGetSetSvcPlace), object: nil)
    }
    
    @objc private func recallAPI() {
        tableView.reCallAPI()
    }
    
    // MARK: Event Handler
    @IBAction func addLocationButtonClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: "AddServiceLocationViewController") as! AddServiceLocationViewController
        present(vc, animated: true, completion: nil)
    }
}

extension ServiceLocationViewController: ServiceLocationTableViewDelegate {
    
    func updateSelectSvcPlaceIdArray(_ selectPIdArray: [Int]) {
        self.serviceLocationVCDelegate?.changeNaviRightButtonTitleWith(selectSvcPlaceCount: selectPIdArray.count)
    }
    
    func deleteSvcPlaceSuccess() {
        self.serviceLocationVCDelegate?.changeNaviRightButtonTitleWith(selectSvcPlaceCount: 0)
    }
    
    func insertSvcPlaceSuccess() {}
    
    func didSelectSvcPlace(model: SvcPlaceModel) {}
}

extension ServiceLocationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.tableView.callAPIWithKeyword(textField.text ?? "")
        return true
    }
}

