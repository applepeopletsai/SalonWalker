//
//  ServiceTimeCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/3.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ServiceTimeCell: UITableViewCell {

    @IBOutlet private weak var weekLabel: UILabel!
    @IBOutlet private weak var fromTimeLabel: UILabel!
    @IBOutlet private weak var toTimeLabel: UILabel!
    @IBOutlet private weak var fromLabel: UILabel!
    @IBOutlet private weak var toLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        resizeLabelFont()
    }
    
    func setupCellWith(week: Int, fromTime: String, toTime: String) {
        self.weekLabel.text = week.transferToWeekString()
        self.fromTimeLabel.text = fromTime
        self.toTimeLabel.text = toTime
    }
    
    private func resizeLabelFont() {
        var timeFont: CGFloat = 26
        var fromToFont: CGFloat = 14
        if SizeTool.isIphone5() {
            timeFont = 22
            fromToFont = 12
        }
        
        var font = UIFont.systemFont(ofSize: timeFont)
        self.fromTimeLabel.font = font
        self.toTimeLabel.font = font
        font = UIFont.systemFont(ofSize: fromToFont)
        self.fromLabel.font = font
        self.toLabel.font = font
    }
    
}
