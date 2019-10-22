//
//  PortfolioViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/30.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class PortfolioViewController: MultipleScrollBaseViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    var designerDetailModel: DesignerDetailModel? {
        didSet {
            if oldValue == nil {
                setupUI()
            }
        }
    }
    
    private var titleArray: [String] = []
    private var photoArray: [[WorksModel]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.alwaysBounceVertical = true
    }
    
    private func setupUI() {
        titleArray.removeAll()
        photoArray.removeAll()
        if let works = designerDetailModel?.works, works.count != 0 {
            titleArray.append(LocalizedString("Lang_DD_009"))
            photoArray.append(works)
        }
        
        if let customer = designerDetailModel?.customer, customer.count != 0 {
            titleArray.append(LocalizedString("Lang_DD_010"))
            photoArray.append(customer)
        }
        
        tableView.reloadData()
    }

}

extension PortfolioViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PortfolioCell.self), for: indexPath) as! PortfolioCell
        cell.setupCellWith(title: titleArray[indexPath.row], photoArray: photoArray[indexPath.row], row: indexPath.row, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return screenHeight * 0.25
    }
}

extension PortfolioViewController: PortfolioCellDelegate {
    
    func watchMoreButtonPress(at index: Int) {
        guard let ouId = designerDetailModel?.ouId else { return  }
        let vc = UIStoryboard(name: kStory_DesignerDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: DesignerPortfolioMainViewController.self)) as! DesignerPortfolioMainViewController
        vc.setupVCWith(ouId: ouId, portfolioType: (index == 0) ? .Personal : .WorkShop)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

