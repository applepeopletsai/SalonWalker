//
//  PersonalInfoViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/30.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class PersonalInfoViewController: MultipleScrollBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var personalInfoArray: [[String?]]?
    private var serviceLocationArray = [SvcPlaceModel]()
    
    var designerDetailModel: DesignerDetailModel? {
        didSet {
            if oldValue == nil {
                setupUI()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.alwaysBounceVertical = true
    }
    
    private func setupUI() {
        var licenseName = ""
        if let licenseNameArray = designerDetailModel?.licenseImg?.enumerated().map({ $0.element.name ?? "" }) {
            licenseNameArray.forEach { name in
                licenseName.append((licenseName.count == 0) ? name : "\n\(name)")
            }
        }
        personalInfoArray = [[LocalizedString("Lang_DD_005"),
                              LocalizedString("Lang_DD_006"),
                              LocalizedString("Lang_RT_014"),
                              LocalizedString("Lang_RT_016")],
                             [designerDetailModel?.nickName,
                             designerDetailModel?.position,
                             String(designerDetailModel?.experience ?? 0) + LocalizedString("Lang_RT_015"),
                             licenseName]]
        if let svcPlace = designerDetailModel?.svcPlace {
            serviceLocationArray = svcPlace
        }
        tableView.reloadData()
    }
}

extension PersonalInfoViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if designerDetailModel != nil {
            return 4
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return personalInfoArray?.first?.count ?? 0
        case 2: return 1
        case 3: return serviceLocationArray.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SelfIntroductionCell.self), for: indexPath) as! SelfIntroductionCell
            cell.contentLabel.text = designerDetailModel?.characterization
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PersonalInfoCell.self), for: indexPath) as! PersonalInfoCell
            cell.setupCellWith(title: personalInfoArray?.first?[indexPath.row], content: personalInfoArray?.last?[indexPath.row])
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PersonalInfoCell.self), for: indexPath) as! PersonalInfoCell
            let content = "\(LocalizedString("Lang_AC_002"))\(designerDetailModel?.missTotal ?? 0)\(LocalizedString("Lang_DD_022"))，\(LocalizedString("Lang_AC_004"))\(designerDetailModel?.cautionTotal ?? 0)\(LocalizedString("Lang_DD_022"))"
            cell.setupCellWith(title: LocalizedString("Lang_DD_023"), content: content)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ServicePositionCell.self), for: indexPath) as! ServicePositionCell
            cell.setupCellWith(model: serviceLocationArray[indexPath.row], indexPath: indexPath)
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            let vc = UIStoryboard(name: kStory_StoreDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: StoreDetailViewController.self)) as! StoreDetailViewController
            vc.setupVCWith(pId: serviceLocationArray[indexPath.row].pId, type: .onlyCheck)
            let naviVC = UINavigationController(rootViewController: vc)
            naviVC.isNavigationBarHidden = true
            self.present(naviVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            let view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
            view.backgroundColor = color_EEEEEE
            header.addSubview(view)
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            return 20
        }
        return CGFloat.leastNormalMagnitude
    }
}
