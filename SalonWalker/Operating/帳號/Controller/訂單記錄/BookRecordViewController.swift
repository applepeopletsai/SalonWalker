//
//  BookRecordViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class BookRecordViewController: BaseViewController {
    
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var countBgView: UIView!
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        apiGetOrderStatusNum()
    }
    
    // MARK: Method
    override func networkDidRecover() {
        apiGetOrderStatusNum()
    }
    
    // MARK: Event Handler
    // 客戶預約訂單
    @IBAction func customerButtonClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: "OrderRecord", bundle: nil).instantiateViewController(withIdentifier: String(describing: CustomerOrderListMainViewController.self)) as! CustomerOrderListMainViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 場地預約訂單
    @IBAction func courtButtonClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: "OrderRecord", bundle: nil).instantiateViewController(withIdentifier: String(describing: SiteOrderListMainViewController.self)) as! SiteOrderListMainViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: API
    private func apiGetOrderStatusNum() {
        if SystemManager.isNetworkReachable(showBanner: false) {
            OperatingManager.apiGetOrderStatusNum(success: { [weak self] (model) in
                guard let weakSelf = self else { return }
                if model?.syscode == 200 {
                    if let count = model?.data?.orderStatusNum, count > 0 {
                        weakSelf.countLabel.isHidden = false
                        weakSelf.countBgView.isHidden = false
                        weakSelf.countLabel.text = String(count.transferToDecimalString())
                    } else {
                        weakSelf.countLabel.isHidden = true
                        weakSelf.countBgView.isHidden = true
                    }
                }
                }, failure: { _ in })
        }
    }
}
