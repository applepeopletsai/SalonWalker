//
//  DesignerInfoCell_NoFav.swift
//  SalonWalker
//
//  Created by Daniel on 2018/5/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol DesignerInfoCell_NoFavDelegate: class {
    func findDesignerButtonPress()
}

class DesignerInfoCell_NoFav: UITableViewCell {

    weak var delegate: DesignerInfoCell_NoFavDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction private func findDesignerButtonPress(_ sender: UIButton) {
        self.delegate?.findDesignerButtonPress()
    }
    
}
