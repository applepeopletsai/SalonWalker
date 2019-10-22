//
//  ShowSchemeTableViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ShowSchemeTableViewCell: UITableViewCell {

    //MARK: IBOutlet
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var userChooseButton: IBInspectableButton!
    //MARK: Property
   
    //MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    //MARK: EventHandler
    @IBAction func userChooseButtonClick(_ sender: UIButton) {
        userChooseButton.isSelected = !userChooseButton.isSelected
    }
    //MARK: Class Method
    func setupCellWith(indexPath: IndexPath, dayArray: [String], priceArray: [Int], unitString: String , cellDidClick: Bool) {
        self.dayLabel.text = dayArray[indexPath.row]
        self.priceLabel.text = "$\(priceArray[indexPath.row])"
        self.unitLabel.text = unitString
    }
}
