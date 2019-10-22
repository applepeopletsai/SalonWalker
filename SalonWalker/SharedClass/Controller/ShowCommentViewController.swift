//
//  ShowCommentViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Cosmos

class ShowCommentViewController: BaseViewController {

    @IBOutlet private weak var starView: CosmosView!
    @IBOutlet private weak var commentLabel: UILabel!
    
    private var model: EvaluateStatusModel.Evaluation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    func setupVCWith(model: EvaluateStatusModel.Evaluation) {
        self.model = model
    }
    
    private func initialize() {
        self.commentLabel.text = model?.comment
        self.starView.rating = Double(model?.point ?? 0)
    }
    
}
