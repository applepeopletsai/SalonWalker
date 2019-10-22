//
//  LanguageSettingTableViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/19.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class LanguageSettingTableViewCell: UITableViewCell {
    
    //MARK: IBOutlet
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var tickImageView: UIImageView!
    
    //MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWith(languageModel: LangModel, isSelect: Bool) {
        self.languageLabel.text = languageModel.langName
        self.tickImageView.isHidden = !isSelect
    }
}
