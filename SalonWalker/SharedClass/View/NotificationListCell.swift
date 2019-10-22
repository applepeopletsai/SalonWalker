//
//  NotificationListCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/12/20.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class NotificationListCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var dotView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWith(model: PushListModel.PushDetailModel) {
        self.titleLabel.text = model.title
        self.contentLabel.text = model.content
        self.dateLabel.text = model.sendTime
        self.dotView.isHidden = (model.pushStatus == 1)
    }

}
