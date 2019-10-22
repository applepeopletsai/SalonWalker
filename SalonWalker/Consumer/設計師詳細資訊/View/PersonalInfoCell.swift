//
//  PersonalInfoCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class PersonalInfoCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCellWith(title: String?, content: String?) {
        self.titleLabel.text = title
        self.contentLabel.text = content
    }

}
