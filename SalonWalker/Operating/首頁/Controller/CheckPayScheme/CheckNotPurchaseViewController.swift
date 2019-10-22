//
//  NotPurchaseViewController.swift
//  PriceScheme
//
//  Created by Scott.Tsai on 2018/4/3.
//  Copyright © 2018年 Scott.Tsai. All rights reserved.
//

import UIKit

class CheckNotPurchaseViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    //MARK: IBOutlet
    @IBOutlet weak var notPurchaseTableView: UITableView!
    
    //MARK: Property
    let cellHeight = UIScreen.main.bounds.width * 120 / 375
    let startDateArray = ["2017/12/19","2017/11/01","2017/03/01","2017/12/19","2017/11/01","2017/03/01","2017/12/19","2017/11/01","2017/03/01","2017/12/19","2017/11/01","2017/03/01"]
    let endDateArray = ["2017/01/20","2017/11/31","2018/05/31","2017/01/20","2017/11/31","2018/05/31","2017/01/20","2017/11/31","2018/05/31","2017/01/20","2017/11/31","2018/05/31"]
    let priceArray = [100,50,8000,10,0,100,50,8000,10,0,100,50]
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notPurchaseTableView.delegate = self
        notPurchaseTableView.dataSource = self
        notPurchaseTableView.separatorStyle = .none
    }
    //MARK: TableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return priceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notPurchaseTableView.dequeueReusableCell(withIdentifier: "CheckNotPurchaseTableViewCell", for: indexPath) as! CheckNotPurchaseTableViewCell
        
        cell.selectionStyle = .none
        cell.setupWithCellFunc(indexPath: indexPath, startDateArray: startDateArray, endDateArray: endDateArray, priceArray: priceArray)
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return cellHeight
    }
}
