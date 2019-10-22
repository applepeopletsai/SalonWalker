//
//  ShowSchemeTableViewCell.swift
//  PriceScheme
//
//  Created by Scott.Tsai on 2018/4/2.
//  Copyright © 2018年 Scott.Tsai. All rights reserved.
//

import UIKit

class CheckShowSchemeTableViewCell: UITableViewCell {

    //MARK: ----------IBOutlet----------
    //星期幾
    @IBOutlet weak var dayLabel: UILabel!
    //價錢
    @IBOutlet weak var priceLabel: UILabel!
    //單位_/次：/時
    @IBOutlet weak var unitLabel: UILabel!
    
    //MARK: ----------Life Cycle----------
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    func setupWithCellFunc(indexPath: IndexPath , dayArray: [String] , priceArray:[Int] , unitString: String){
        
        self.priceLabel.text = "$\(priceArray[indexPath.row])"
        self.dayLabel.text = dayArray[indexPath.row]
        self.unitLabel.text = unitString
    }
}
