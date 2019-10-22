//
//  CutFixPriceViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/30.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class CutFixPriceViewController: BaseViewController {
    
    
    @IBOutlet weak var topLabel: IBInspectableLabel!
    
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBOutlet weak var itemLabel: IBInspectableLabel!
    @IBOutlet weak var texField: IBInspectableTextField!
    
    @IBOutlet weak var hairCutPriceView: UIView!
    @IBOutlet weak var hairCutPriceViewHeight: NSLayoutConstraint!
    override func viewDidLoad() {
       
        super.viewDidLoad()

    }

    @IBAction func topBackButtonClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func topSaveButtonClick(_ sender: UIButton) {
    }
}
