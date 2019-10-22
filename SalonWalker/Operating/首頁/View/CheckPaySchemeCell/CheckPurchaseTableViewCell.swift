//
//  PurchaseTableViewCell.swift
//  PriceScheme
//
//  Created by Scott.Tsai on 2018/4/3.
//  Copyright © 2018年 Scott.Tsai. All rights reserved.
//

import UIKit

class CheckPurchaseTableViewCell: UITableViewCell {

    //MARK: IBOutlet
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    //MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    //MARK: Class Method
    func setupWithCellFunc(indexPath: IndexPath, startDateArray:[String], endDateArray:[String], priceArray:[Int]){
        self.dateLabel.text = "\(startDateArray[indexPath.row]) 至 \(endDateArray[indexPath.row])"
        self.priceLabel.text = "$\(priceArray[indexPath.row])"
    }
}
