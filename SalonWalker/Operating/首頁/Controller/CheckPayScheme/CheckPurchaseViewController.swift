//
//  PurchaseViewController.swift
//  PriceScheme
//
//  Created by Scott.Tsai on 2018/4/3.
//  Copyright © 2018年 Scott.Tsai. All rights reserved.
//

import UIKit

class CheckPurchaseViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    //MARK: IBOutlet
    @IBOutlet weak var purchaseTableView: UITableView!
    
    //MARK: Property
    let cellHeight = UIScreen.main.bounds.width * 120 / 375
    let startDateArray = ["2017/07/01","2017/08/01","2017/12/01","2017/07/01","2017/08/01","2017/12/01","2017/07/01","2017/08/01","2017/12/01","2017/07/01","2017/08/01","2017/12/01","2017/07/01","2017/08/01","2017/12/01"]
    let endDateArray = ["2017/08/15","2017/12/31","2018/01/31","2017/08/15","2017/12/31","2018/01/31","2017/08/15","2017/12/31","2018/01/31","2017/08/15","2017/12/31","2018/01/31","2017/08/15","2017/12/31","2018/01/31"]
    let priceArray = [1200,800,10,0,1000,1200,800,10,0,1000,1200,800,10,0,1000]
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        purchaseTableView.delegate = self
        purchaseTableView.dataSource = self
        purchaseTableView.separatorStyle = .none
        
    }
    //MARK: TableView Datasouce
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return priceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = purchaseTableView.dequeueReusableCell(withIdentifier: "CheckPurchaseTableViewCell", for: indexPath) as! CheckPurchaseTableViewCell
        
        cell.selectionStyle = .none
        
        cell.setupWithCellFunc(indexPath: indexPath, startDateArray: startDateArray, endDateArray: endDateArray, priceArray: priceArray)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return cellHeight
    }
}
