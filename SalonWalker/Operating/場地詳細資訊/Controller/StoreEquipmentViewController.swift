//
//  TableViewController.swift
//  TabBar_practice
//
//  Created by Skywind on 2018/3/6.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class StoreEquipmentViewController: MultipleScrollBaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var firstSectionArray = [EquipmentModel]()
    private var secondSectionArray = [EquipmentModel]()
  
    var providerDetailModel: ProviderDetailModel? {
        didSet {
            if oldValue == nil {
                setupUI()
            }
        }
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.alwaysBounceVertical = true
    }
    
    // MARK: Method
    private func setupUI() {
        firstSectionArray.removeAll()
        secondSectionArray.removeAll()
        if let equipments = providerDetailModel?.equipment {
            for equipment in equipments {
                if equipment.characterization.count == 0 {
                    firstSectionArray.append(equipment)
                } else {
                    secondSectionArray.append(equipment)
                }
            }
            tableView.reloadData()
        }
    }

    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? firstSectionArray.count : secondSectionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoreEquipmentCell", for: indexPath) as! StoreEquipmentCell
            cell.setupCellWith(model: firstSectionArray[indexPath.row], hideTitle: (indexPath.row != 0))
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoreEquipmentSuppliesCell", for: indexPath) as! StoreEquipmentSuppliesCell
            cell.setupCellWithModel(secondSectionArray[indexPath.row])
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 1 && firstSectionArray.count > 0 && secondSectionArray.count > 0) ? 1.0 : CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1, firstSectionArray.count > 0, secondSectionArray.count > 0 {
            let baseView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1.0))
            let view = UIView(frame: CGRect(x: 25.0, y: 0, width: screenWidth - 45.0, height: 1.0))
            view.backgroundColor = color_EEEEEE
            baseView.addSubview(view)
            return baseView
        }
        return nil
    }
    
}
