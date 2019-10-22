//
//  BusinessTimeView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/22.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class BusinessTimeView: UIView {

    static func initWith(frame: CGRect, serviceTimeArray: [[[Double]]]) -> CandleStickChartView {
        let chartView = CandleStickChartView(frame: frame)
        
        chartView.chartDescription?.enabled = false
        chartView.setScaleEnabled(false)
        chartView.dragEnabled = false
        chartView.legend.enabled = false
        
        let l = chartView.legend
        l.horizontalAlignment = .center
        
        chartView.rightAxis.enabled = false
        
        chartView.leftAxis.granularity = 1
        chartView.leftAxis.axisMinimum = 8
        chartView.leftAxis.axisMaximum = 24
        chartView.leftAxis.labelCount = 17
        chartView.leftAxis.drawAxisLineEnabled = false
        
        let xAxisFormatter = IndexAxisValueFormatter(values: [LocalizedString("Lang_GE_036"),LocalizedString("Lang_GE_037"),LocalizedString("Lang_GE_038"),LocalizedString("Lang_GE_039"),LocalizedString("Lang_GE_040"),LocalizedString("Lang_GE_041"),LocalizedString("Lang_GE_042")])
        chartView.xAxis.valueFormatter = xAxisFormatter
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelFont = UIFont.systemFont(ofSize: 12)
        chartView.data = generateCandleDataWithServiceTimeArray(serviceTimeArray)
        
        return chartView
    }
    
    private static func generateCandleDataWithServiceTimeArray(_ array: [[[Double]]]) -> CandleChartData {
        var sets = [CandleChartDataSet]()
        if array.count == 7 {
            for i in 0..<array.count {
                var entries = [CandleChartDataEntry]()
                for time in array[i] {
                    let startValue = Double(32 - (time.first ?? 32))
                    let endValue = Double(32 - (time.last ?? 32))
                    let entry = CandleChartDataEntry(x: Double(i), shadowH: endValue, shadowL: startValue, open: endValue , close: startValue)
                    entries.append(entry)
                }
                
                let set = CandleChartDataSet(values: entries, label: nil)
                set.increasingColor = (i < 5) ? color_8F92F5 : color_2F10A0
                set.increasingFilled = true
                set.drawValuesEnabled = false
                set.highlightEnabled = false
                set.barSpace = 0.25
                
                sets.append(set)
            }
        }
        return CandleChartData(dataSets: sets)
    }
}
