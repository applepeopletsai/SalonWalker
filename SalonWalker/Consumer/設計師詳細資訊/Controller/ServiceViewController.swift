//
//  ServiceViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/30.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ServiceViewController: MultipleScrollBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var designerDetailModel: DesignerDetailModel? {
        didSet {
            if oldValue == nil {
                setupUI()
            }
        }
    }
    
    private var paymentType: String = ""
    private var serviceItems: [ServiceItemModel] = []

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.alwaysBounceVertical = true
        registerHeaderView()
    }
    
    // MARK: Method
    private func registerHeaderView() {
        tableView.register(UINib(nibName: "ServicePaymentHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "ServicePaymentHeaderView")
        tableView.register(UINib(nibName: "ServiceItemHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "ServiceItemHeaderView")
    }
    
    private func setupUI() {
        if let model = designerDetailModel {
            paymentType = DesignerServiceManager.getPaymentType(model)
            serviceItems = DesignerServiceManager.getServiceItems(model)
            tableView.reloadData()
        }
    }
}

extension ServiceViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if designerDetailModel != nil {
            return serviceItems.count + 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            return serviceItems[section - 1].product?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section != 0 {
           let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ServiceProductCell.self), for: indexPath) as! ServiceProductCell
            if let model = serviceItems[indexPath.section - 1].product?[indexPath.row] {
                cell.setupCellWith(model: model, hiddenLine: (serviceItems[indexPath.section - 1].product?.count == indexPath.row + 1))
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            // 付費方式
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ServicePaymentHeaderView") as! ServicePaymentHeaderView
            headerView.setupHeaderViewWithContent(paymentType)
            return headerView
        } else {
            // 服務項目
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ServiceItemHeaderView") as! ServiceItemHeaderView
            headerView.gestureRecognizers?.forEach({ (ges) in
                headerView.removeGestureRecognizer(ges)
            })
            headerView.setupHeaderViewWith(model: serviceItems[section - 1], section: section - 1)
            if serviceItems[section - 1].product?.count != 0 {
                let ges = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
                ges.numberOfTapsRequired = 1
                headerView.addGestureRecognizer(ges)
            }
            return headerView
        }
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        if let view = sender.view as? ServiceItemHeaderView {
            serviceItems[view.tag].expand = !serviceItems[view.tag].expand
            tableView.reloadSections(IndexSet.init(integer: view.tag + 1), with: .none)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: view.tag + 1), at: .none, animated: true)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return (serviceItems[indexPath.section - 1].expand) ? UITableView.automaticDimension : CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
