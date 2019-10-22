//
//  ServiceTimeChartCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/3.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ServiceTimeChartCell: UITableViewCell {

    private var businessTimeView: CandleStickChartView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWith(cellHeight: CGFloat, serviceTimeArray: [[OpenHourModel]]) {
        
        for view in self.contentView.subviews {
            if view.tag == -999 {
                view.removeFromSuperview()
            }
        }
        let leftMargin: CGFloat = 20.0
        let rightMargin: CGFloat = 35.0
        let bottomMargin: CGFloat = 20.0
        let x = leftMargin
        let y: CGFloat = 20 + 15 + 10
        
        let chart = BusinessTimeView.initWith(frame: CGRect(x: x, y: y, width: screenWidth - leftMargin - rightMargin, height: cellHeight - y - bottomMargin), serviceTimeArray: transferToDouble(serviceTimeArray))
        self.contentView.addSubview(chart)
        chart.tag = -999
        
        self.businessTimeView = chart
    }
    
    private func transferToDouble(_ array: [[OpenHourModel]]) -> [[[Double]]] {
        var result = [[[Double]]]()
        for arr in array {
            var doubleArray = [[Double]]()
            for model in arr {
                var double = [Double]()
                if let fromPrefix = Double(model.from.prefix(2)), let fromSuffix = Double(model.from.suffix(2)) {
                    double.append(fromPrefix + fromSuffix / 60)
                }
                if let endPrefix = Double(model.end.prefix(2)), let endSuffix = Double(model.end.suffix(2)) {
                    double.append(endPrefix + endSuffix / 60)
                }
                doubleArray.append(double)
            }
            result.append(doubleArray)
        }
        return result
    }
    
}
