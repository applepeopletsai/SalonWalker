//
//  NotificationDetailViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/12/21.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class NotificationDetailViewController: BaseViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var contentTextView: UITextView!
    
    private var model: PushListModel.PushDetailModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
    }

    func setupVCWith(model: PushListModel.PushDetailModel) {
        self.model = model
    }
    
    private func configureVC() {
        self.titleLabel.text = model?.title
        self.timeLabel.text = model?.sendTime
        self.contentTextView.text = model?.content
    }
    
}
