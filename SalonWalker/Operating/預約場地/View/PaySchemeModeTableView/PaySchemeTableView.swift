//
//  PaySchemeModeTableView.swift
//  SalonWalker
//
//  Created by Scott.Tsai on 2018/4/28.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum PaySchemeType {
    case hour       //小時
    case times      //次數
    case longRent   //長租
}

protocol PaySchemeTableViewDelegate: class {
    func didSelectPaymentTypeWithModel(_ model: Codable)
}

class PaySchemeTableView: UITableView {

    private var hourAndTimePriceArray: [HoursAndTimesPricesModel]?
    private var longLeasePriceArray: [LongLeasePricesModel]?
    private var showSchemeType: ShowPaySchemeType = .check
    private var chooseSchemeType: PaySchemeType = .hour
    private weak var paySchemeTableViewDelegate: PaySchemeTableViewDelegate?
    
    private var selectIndexPath: IndexPath?
    private var selectModel: Codable?
    
    override func awakeFromNib() {
        self.delegate = self
        self.dataSource = self
        
        self.register(UINib(nibName: "PaySchemeTableViewCell", bundle: nil), forCellReuseIdentifier: "PaySchemeTableViewCell")
    }
    
    func setupTableViewWith(hourAndTimePriceArray: [HoursAndTimesPricesModel]?, longLeasePriceArray: [LongLeasePricesModel]?, showSchemeType: ShowPaySchemeType ,chooseSchemeType: PaySchemeType, delegate: PaySchemeTableViewDelegate?) {
        self.hourAndTimePriceArray = hourAndTimePriceArray
        self.longLeasePriceArray = longLeasePriceArray
        self.showSchemeType = showSchemeType
        self.chooseSchemeType = chooseSchemeType
        self.paySchemeTableViewDelegate = delegate
    }
    
    func resetSelectStatus() {
        self.selectIndexPath = nil
        self.selectModel = nil
        self.reloadData()
    }
}

extension PaySchemeTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hourAndTimePriceArray?.count ?? longLeasePriceArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PaySchemeTableViewCell.self), for: indexPath) as! PaySchemeTableViewCell
        let select = (selectIndexPath == indexPath)
        let model: Codable = hourAndTimePriceArray?[indexPath.row] ?? longLeasePriceArray?[indexPath.row]
        cell.setupCellWith(model: model, showSchemeType: showSchemeType, chooseSchemeType: chooseSchemeType, select: select)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model: Codable = hourAndTimePriceArray?[indexPath.row] ?? longLeasePriceArray?[indexPath.row]
        // 長租方案下，過期的方案不可選擇
        if model is LongLeasePricesModel {
            if let endDay = (model as? LongLeasePricesModel)?.endDay, endDay.transferToDate(dateFormat: "yyyy-MM-dd") < Date() {
                return
            }
        }
        self.selectModel = model
        self.selectIndexPath = indexPath
        self.paySchemeTableViewDelegate?.didSelectPaymentTypeWithModel(model)
        
        self.reloadData()
    }
}
