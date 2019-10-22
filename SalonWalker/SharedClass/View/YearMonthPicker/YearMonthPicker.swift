//
//  YearMonthPicker.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/20.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol YearMonthPickerDelegate: class {
    func didSelectItem(month: Int, year: Int)
}

class YearMonthPicker: UIPickerView {

    var currentYear: Int?
    var currentMonth: Int?
    weak var yearMonthPickerDelegate: YearMonthPickerDelegate?
    
    private var months = [String]()
    private var years = [Int]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        var years: [Int] = []
        if years.count == 0 {
            let currentYear = Calendar.current.component(.year, from: NSDate() as Date)
            var year_2019 = 2019
            // 行事曆從2019開始
            // 顯示從年份從2019到今年的下一年
            let count = currentYear - year_2019 + 1
            for _ in 0...count {
                years.append(year_2019)
                year_2019 += 1
            }
        }
        self.years = years
        
        var months: [String] = []
        var month = 0
        for _ in 1...12 {
            months.append(DateFormatter().monthSymbols[month].capitalized)
            month += 1
        }
        self.months = months
        
        self.delegate = self
        self.dataSource = self
        
        let currentMonth = Calendar.current.component(.month, from: Date())
        self.currentMonth = currentMonth
        self.selectRow(currentMonth - 1, inComponent: 0, animated: false)
        
        let currentYear = Calendar.current.component(.year, from: Date())
        self.currentYear = currentYear
        self.selectRow(years.index(of: currentYear)!, inComponent: 1, animated: false)
    }
}

extension YearMonthPicker: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return months.count
        case 1: return years.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return months[row]
        case 1: return "\(years[row])"
        default: return nil
        }
    }
}

extension YearMonthPicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let month = self.selectedRow(inComponent: 0) + 1
        let year = years[self.selectedRow(inComponent: 1)]
        
        yearMonthPickerDelegate?.didSelectItem(month: month, year: year)
    }
}
