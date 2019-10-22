//
//  PurchaseTableViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class PurchaseTableViewCell: UITableViewCell {

    //MARK: IBOulet
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var userChooseButton: IBInspectableButton!
    
    //MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        userChooseButton.isSelected = false
    }
    
    //MARK: EventHandler
    @IBAction func userChooseButtonClick(_ sender: UIButton) {
        userChooseButton.isSelected = !userChooseButton.isSelected
    }
    
    //MARK: Class Method
    func setupCellWith(indexPath: IndexPath , startDateArray: [String], endDateArray: [String], priceArray: [Int]) {
        self.timeLabel.text = "\(startDateArray[indexPath.row]) 至 \(endDateArray[indexPath.row])"
        self.priceLabel.text = "$\(priceArray[indexPath.row])"
    }
}
