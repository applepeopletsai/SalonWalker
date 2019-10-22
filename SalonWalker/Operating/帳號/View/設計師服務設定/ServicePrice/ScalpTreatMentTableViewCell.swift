//
//  ScalpTreatMentTableViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/18.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ScalpTreatMentTableViewCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var priceTextField: UILabel!
    
    private var index = 0
    private var tickButtonIsClick = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    //MARK: TextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    //MARK: EventHandler
    @IBAction func tickButtonClick(_ sender: UIButton) {
        tickButtonIsClick = !tickButtonIsClick
        if tickButtonIsClick {
            self.tickImage.image = UIImage(named: "checkbox_checked")
        } else {
            self.tickImage.image = UIImage(named: "checkbox_normal")
        }
    }
    
    @IBAction func photoButtonClick(_ sender: UIButton) {
        print("******** 第 \(index) 列 照片按鈕觸發 ********")
    }
    
    func setupCellWith(index: Int , titleString: String) {
        self.index = index
        self.titleLabel.text = titleString
    }
}
