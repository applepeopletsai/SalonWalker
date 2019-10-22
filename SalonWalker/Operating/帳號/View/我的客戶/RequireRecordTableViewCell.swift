//
//  RequireRecordTableViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/16.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class RequireRecordTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWithModel(_ model: CustomerSvcHistoryModel.SvcHistory) {
        self.dateLabel.text = model.orderTime
        
        var serviceContent = ""
        for content in model.svcContent.svcCategory {
            if serviceContent.count == 0 {
                serviceContent.append(content.name)
            } else {
                serviceContent.append("/\(content.name)")
            }
        }
        self.itemLabel.text = serviceContent
    }
    
}
