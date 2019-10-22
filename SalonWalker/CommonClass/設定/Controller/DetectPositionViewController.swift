//
//  DetectPositionViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/19.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class DetectPositionViewController: BaseViewController {
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    //MARK: EventHandler
    //返回
    @IBAction func topBackButtonClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    //GPS自動偵測
    @IBAction func GPSDetectSwitchClick(_ sender: UISwitch) {
        if sender.isOn {
            print("******** GPS自動偵測 ********")
        }
    }
    //個人資料
    @IBAction func personalDataSettingSwitchClick(_ sender: UISwitch) {
        if sender.isOn {
            print("******** 依照個人資料設定 ********")
        }
    }
}
