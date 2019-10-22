//
//  CheckPriceSchemeViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class CheckPriceSchemeViewController: BaseViewController {
    
    //MARK: IBOutlet
    @IBOutlet weak var topLabel: UILabel!
    
    //MARK: IBOutlet
    var titleString: String = ""
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        topLabel.text = titleString
    }
    //MARK: EventHandle
    
    @IBAction func backArrowButtonClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func upperButtonHandler(_ sender: UIButton) {
        let dayArray = [LocalizedString("Monday"),LocalizedString("Tuesday"),LocalizedString("Wednesday")]
        let priceArray = [300,350,30012172456412131]
        let unitString = LocalizedString("/Hour")
        let titleString = LocalizedString("Hour")
        let nextVC = UIStoryboard(name: kStory_StoreHomePage, bundle: nil).instantiateViewController(withIdentifier: "CheckShowSchemeViewController") as! CheckShowSchemeViewController
        
        nextVC.changeViewControllerInitFunc(priceArray: priceArray, dayArray: dayArray, unitString: unitString , titleString: titleString)
        
        present(nextVC, animated: true, completion: nil)
    }
    
    @IBAction func centralButtonHandler(_ sender: UIButton) {
        
        let dayArray = [LocalizedString("Tuesday"),LocalizedString("Sunday"),LocalizedString("Wednesday"),LocalizedString("Monday"),LocalizedString("Friday")]
        let priceArray = [400,500,300,800,600]
        let unitString = LocalizedString("/Times")
        let titleString = LocalizedString("Times")
        let nextVC = UIStoryboard(name: kStory_StoreHomePage, bundle: nil).instantiateViewController(withIdentifier: "CheckShowSchemeViewController") as! CheckShowSchemeViewController
        
        nextVC.changeViewControllerInitFunc(priceArray: priceArray, dayArray: dayArray, unitString: unitString , titleString: titleString)
        
        present(nextVC, animated: true, completion: nil)
    }
    
    @IBAction func downButtonHandler(_ sender: UIButton) {
        
        let nextVC = UIStoryboard(name: kStory_StoreHomePage, bundle: nil).instantiateViewController(withIdentifier: "CheckPurchaseRecordViewController") as! CheckPurchaseRecordViewController
        let titleString = LocalizedString("LongTermRent")
        nextVC.changeViewControllerInitFunc(titleString: titleString)
        
        present(nextVC, animated: true, completion: nil)
    }
}
