//
//  ReserveDesignerViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/6.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ReserveDesignerViewController: BaseViewController {

    @IBOutlet private weak var tableView: ServiceItemsTableView!
    @IBOutlet private weak var naviTitleLabel: UILabel!
    
    private var designerDetailModel: DesignerDetailModel?
    private var svcItemArray = [SvcCategoryModel]()
    private var designerSvcItemModel: DesignerSvcItemsModel?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.callAPI()
    }

    deinit {
        debugPrint("離開預約流程")
        ReservationManager.shared.reservationDetailModel = nil
    }
    
    // MARK: Method
    override func networkDidRecover() {
        tableView.callAPI()
    }
    
    func setupVCWith(model: DesignerDetailModel?) {
        self.designerDetailModel = model
    }
    
    private func configureUI() {
        naviTitleLabel.text = designerDetailModel?.nickName
        if let model = designerDetailModel {
            tableView.setupTableViewWith(model: model, targetViewController: self)
        }
    }
}


