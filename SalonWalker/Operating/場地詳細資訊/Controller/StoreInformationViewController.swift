//
//  ViewController.swift
//  TabBar_practice
//
//  Created by Skywind on 2018/3/6.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class StoreInformationViewController: MultipleScrollBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private weak var tableView: UITableView!
    private let mapCellHeight: CGFloat = screenHeight / 667 * 300
    private var storeInfoArray: [[String?]]?
    
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
        storeInfoArray = [[LocalizedString("Lang_RT_050"),
                           LocalizedString("Lang_RT_030"),
                           LocalizedString("Lang_RT_031"),
                           LocalizedString("Lang_RT_035")],
                          [providerDetailModel?.address,
                           providerDetailModel?.tel,
                           providerDetailModel?.uniformNumber,
                           providerDetailModel?.contactInformation]]
        tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return storeInfoArray?.first?.count ?? 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SelfIntroductionCell.self), for: indexPath) as! SelfIntroductionCell
            cell.contentLabel.text = providerDetailModel?.characterization
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PersonalInfoCell.self), for: indexPath) as! PersonalInfoCell
            cell.setupCellWith(title: storeInfoArray?.first?[indexPath.row], content: storeInfoArray?.last?[indexPath.row])
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PersonalInfoCell.self), for: indexPath) as! PersonalInfoCell
            let content = "\(LocalizedString("Lang_AC_002"))\(providerDetailModel?.missTotal ?? 0)\(LocalizedString("Lang_DD_022"))，\(LocalizedString("Lang_AC_004"))\(providerDetailModel?.cautionTotal ?? 0)\(LocalizedString("Lang_DD_022"))"
            cell.setupCellWith(title: LocalizedString("Lang_DD_023"), content: content)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoreInfoMapCell", for: indexPath) as! StoreInfoMapCell
            cell.setupCellWithLocation(lat: providerDetailModel?.lat, lng: providerDetailModel?.lng)
            return cell
        default: return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            return mapCellHeight
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            return mapCellHeight
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            let header = UIView(frame: CGRect.zero)
            let view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
            view.backgroundColor = color_EEEEEE
            header.addSubview(view)
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        } else if section == 3 {
            return 1
        } else {
            return 20
        }
    }
}

