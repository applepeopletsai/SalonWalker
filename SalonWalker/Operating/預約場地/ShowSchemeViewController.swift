//
//  ShowSchemeViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ShowSchemeViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    //MARK: IBOutlet
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Property
    var titleString: String = ""
    var unitString: String = ""
    var dayArray = ["星期一","星期二","星期五","星期三","星期六","星期四"]
    var priceArray = [20,3000,100,10000,200000,3000000]
    var cellDidClick = false
    var schemeModeString: String = ""
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.topLabel.text = titleString
    }
    //MARK: TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowSchemeTableViewCell", for: indexPath) as! ShowSchemeTableViewCell
        cell.setupCellWith(indexPath: indexPath, dayArray: dayArray, priceArray: priceArray, unitString: unitString, cellDidClick: cellDidClick)

        return cell
    }
    //MARK: TableView DataSource
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    //MARK: EventHandler
    @IBAction func topBackButtonClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func topConfirmButtonClick(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: kStory_StoreHomePage, bundle: nil).instantiateViewController(withIdentifier: "BookDateViewController") as! BookDateViewController
        nextVC.setSchemeMode(schemeModeString: schemeModeString)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    //MARK: Class Method
    func setSchemeMode(titleString: String , unitString: String) {
        self.titleString = titleString
        self.schemeModeString = titleString
        self.unitString = unitString
    }
    
}
