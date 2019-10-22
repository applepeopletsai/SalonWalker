//
//  ServiceTimeViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/30.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ServiceTimeViewController: MultipleScrollBaseViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    var designerDetailModel: DesignerDetailModel? {
        didSet {
            if oldValue == nil {
                setupUI()
            }
        }
    }
    
    private var chartCellHeight: CGFloat {
        if SizeTool.isIphoneX() {
            return screenHeight * 0.4
        } else {
            return screenHeight * 0.45
        }
    }
    
    private var serviceTimeArrayForChart: [[OpenHourModel]] = []
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.alwaysBounceVertical = true
    }

    // MARK: Method
    private func setupUI() {
        if let openHour = designerDetailModel?.openHour {
            serviceTimeArrayForChart = DetailManager.transferToWorkTimeArrayForChart(openHour)
            // 星期天從第一個移到最後一個
            serviceTimeArrayForChart.append(serviceTimeArrayForChart.removeFirst())
            tableView.reloadData()
        }
    }
}

extension ServiceTimeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = designerDetailModel?.openHour?.count {
            return count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < (designerDetailModel?.openHour?.count ?? 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ServiceTimeCell.self), for: indexPath) as! ServiceTimeCell
            if let openHour = designerDetailModel?.openHour![indexPath.row] {
                cell.setupCellWith(week: openHour.weekDay, fromTime: openHour.from, toTime: openHour.end)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ServiceTimeChartCell.self), for: indexPath) as! ServiceTimeChartCell
            cell.setupCellWith(cellHeight: chartCellHeight, serviceTimeArray: serviceTimeArrayForChart)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < (designerDetailModel?.openHour?.count ?? 0) {
            return screenHeight * 0.1
        } else {
            return chartCellHeight
        }
    }
}

