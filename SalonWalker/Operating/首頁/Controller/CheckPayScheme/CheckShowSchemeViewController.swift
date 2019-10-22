//
//  ShowSchemeViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class CheckShowSchemeViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    //MARK: IBOutlet
    @IBOutlet weak var showSchemeTableView: UITableView!
    @IBOutlet weak var topLabel: UILabel!
   
    //MARK: Property
    var dayArray : [String] = ["星期三","星期日","星期二"]
    var priceArray : [Int] = [300,350,300]
    var cellHeight = UIScreen.main.bounds.width * 108 / 375
    var unitString = " "
    var titleString = " "
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showSchemeTableView.delegate = self
        showSchemeTableView.dataSource = self
        showSchemeTableView.separatorStyle = .none
        self.topLabel.text = titleString
    }
    
    //MARK: TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return priceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = showSchemeTableView.dequeueReusableCell(withIdentifier: "CheckShowSchemeTableViewCell", for: indexPath) as! CheckShowSchemeTableViewCell
        
        cell.selectionStyle = .none
        cell.setupWithCellFunc(indexPath: indexPath, dayArray: dayArray, priceArray: priceArray , unitString: unitString)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return cellHeight
    }
    
    //MARK: EvenHandler
    @IBAction func topBackButtonClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Class Method
    func changeViewControllerInitFunc( priceArray:[Int] , dayArray: [String] , unitString :String , titleString: String){
        
        self.dayArray = dayArray
        self.priceArray = priceArray
        self.unitString = unitString
        self.titleString = titleString
    }
}
