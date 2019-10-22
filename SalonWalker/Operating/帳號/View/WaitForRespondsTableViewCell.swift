//
//  WaitForRespondTableViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class WaitForRespondsTableViewCell: UITableViewCell {

    //MARK: IBOutlet
    @IBOutlet weak var customerImage: UIImageView!
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.x += 15
            frame.origin.y += 6
            frame.size.width -= 30
            frame.size.height -= 12
            super.frame = frame
        }
    }
        
    //MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.customerImage.layer.cornerRadius = self.customerImage.bounds.width / 2
        self.customerImage.layer.masksToBounds = true
    }
}
