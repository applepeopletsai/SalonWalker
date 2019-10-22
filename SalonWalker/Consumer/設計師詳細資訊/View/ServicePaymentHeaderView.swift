//
//  ServicePaymentHeaderView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/7/11.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ServicePaymentHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var contentLabel: UILabel!
    
    func setupHeaderViewWithContent(_ content: String) {
        self.contentLabel.text = content
    }
}
