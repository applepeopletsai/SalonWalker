//
//  CommentViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/12.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Cosmos

class CommentViewController: BaseViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var evaluationAveStarView: CosmosView!
    @IBOutlet private weak var evaluationAveLabel: UILabel!
    @IBOutlet private weak var evaluationCountLabel: UILabel!
    @IBOutlet private weak var fiveStarProgressView: StarProgressView!
    @IBOutlet private weak var fourStarProgressView: StarProgressView!
    @IBOutlet private weak var threeStarProgressView: StarProgressView!
    @IBOutlet private weak var twoStarProgressView: StarProgressView!
    @IBOutlet private weak var oneStarProgressView: StarProgressView!
    @IBOutlet private weak var fiveStarLabel: UILabel!
    @IBOutlet private weak var fourStarLabel: UILabel!
    @IBOutlet private weak var threeStarLabel: UILabel!
    @IBOutlet private weak var twoStarLabel: UILabel!
    @IBOutlet private weak var oneStarLabel: UILabel!
    
    private var dId: Int?
    private var pId: Int?
    private var evaluateDetailModel: EvaluateDetailModel?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
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
        if evaluateDetailModel == nil {
            apiGetEvaluateDetail()
        }
    }
    
    func setupVCWith(dId: Int?, pId: Int?) {
        self.dId = dId
        self.pId = pId
    }
    
    private func setupUI() {
        if let model = evaluateDetailModel {
            self.tableView.reloadData()
            
            self.evaluationAveLabel.text = "\(model.evaluationAve)"
            self.evaluationCountLabel.text = LocalizedString("Lang_DD_015") + "：\(model.evaluationTotal)則"
            self.evaluationAveStarView.rating = model.evaluationAve
            
            self.fiveStarLabel.text = "\(model.fivePointPct)%"
            self.fourStarLabel.text = "\(model.fourPointPct)%"
            self.threeStarLabel.text = "\(model.threePointPct)%"
            self.twoStarLabel.text = "\(model.twoPointPct)%"
            self.oneStarLabel.text = "\(model.onePointPct)%"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.fiveStarProgressView.currentValue(CGFloat(model.fivePointPct))
                self.fourStarProgressView.currentValue(CGFloat(model.fourPointPct))
                self.threeStarProgressView.currentValue(CGFloat(model.threePointPct))
                self.twoStarProgressView.currentValue(CGFloat(model.twoPointPct))
                self.oneStarProgressView.currentValue(CGFloat(model.onePointPct))
            }
        }
    }
    
    // MARK: API
    private func apiGetEvaluateDetail() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            DetailManager.apiGetEvaluateDetail(dId: dId, pId: pId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.evaluateDetailModel = model?.data
                    self.setupUI()
                    self.removeMaskView()
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
                }, failure: { [unowned self] (error) in
                    self.removeMaskView()
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension CommentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return evaluateDetailModel?.evaluationList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CommentCell.self), for: indexPath) as! CommentCell
        if let model = evaluateDetailModel?.evaluationList?[indexPath.row] {
            cell.setupCellWith(model)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}


