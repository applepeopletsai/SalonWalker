//
//  CalendarCollectionView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import JTAppleCalendar

enum CalendarMode {
    case month, week
}

protocol CalendarCollectionViewDelegate: class {
    func visibleDateChanged(startDate: Date, endDate: Date)
    func didSelectDate(_ date: Date)
    func didChangeMode(_ mode: CalendarMode)
}

class CalendarCollectionView: JTAppleCalendarView {
    
    weak var calendarCollectionViewDelegate: CalendarCollectionViewDelegate?
    
    fileprivate var showDotDateArray = [Date]()
    fileprivate var mode: CalendarMode = .month
    fileprivate var firstDayOfWeekMode = Date()
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ibCalendarDataSource = self
        self.ibCalendarDelegate = self
        registerCell()
        setupCalendar()
        setupSwipe()
    }
    
    // MARK: Method
    func shouldShowDotDate(date: [Date]) {
        self.showDotDateArray = date
        self.reloadData()
    }
    
    private func registerCell() {
        self.register(UINib(nibName: String(describing: CalendarCollectionCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CalendarCollectionCell.self))
    }
    
    private func setupCalendar() {
        self.visibleDates { [unowned self] (visibleDates: DateSegmentInfo) in
            self.dateChanged(from: visibleDates)
        }
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 1
        self.layer.masksToBounds = false
    }
    
    private func setupSwipe() {
        let up = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        up.direction = .up
        up.numberOfTouchesRequired = 1
        
        let down = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        down.direction = .down
        down.numberOfTouchesRequired = 1
        
        self.addGestureRecognizer(up)
        self.addGestureRecognizer(down)
    }
    
    @objc private func swipe(_ sender: UISwipeGestureRecognizer) {
        if (mode == .week && sender.direction == .up) ||
            (mode == .month && sender.direction == .down) {
            return
        }
        
        mode = (sender.direction == .up) ? .week : .month
        
        let selectDate = self.selectedDates
        let dateToScroll = self.scrollToDateAfterSwipe()
        
        calendarCollectionViewDelegate?.didChangeMode(mode)

        self.reloadData(withanchor: nil, completionHandler: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.scrollToDate(dateToScroll, triggerScrollToDateDelegate: true, animateScroll: false, completionHandler: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.selectDates(selectDate, triggerSelectionDelegate: false)
            })
        })
    }
    
    private func dateChanged(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date, let endDate = visibleDates.monthDates.last?.date else { return }
        if mode == .week { firstDayOfWeekMode = startDate }
        calendarCollectionViewDelegate?.visibleDateChanged(startDate: startDate, endDate: endDate)
    }
    
    private func configureVisibleCellWith(cell: JTAppleCell, cellState: CellState, date: Date) {
        guard let cell = cell as? CalendarCollectionCell  else { return }
        cell.dayLabel.text = cellState.text
        handleCellSelectionWith(cell: cell, cellState: cellState)
    }
    
    private func handleCellSelectionWith(cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCollectionCell else { return }
        
        if mode == .month && cellState.dateBelongsTo != .thisMonth {
            cell.dayLabel.textColor = .gray
        } else {
            cell.dayLabel.textColor = (cellState.isSelected) ? color_0087FF : .black
        }
        cell.dotView.backgroundColor = (cellState.isSelected) ? color_0087FF : color_B3B3B3
        cell.dotView.isHidden = !showDotDateArray.contains(cellState.date)
    }
    
    private func scrollToDateAfterSwipe() -> Date {
        let currentDates = self.visibleDates().monthDates.map{ $0.date }
        let currentYear = Calendar.current.component(.year, from: currentDates.last ?? Date())
        let currentMonth = Set(currentDates.map{ Calendar.current.component(.month, from: $0) }).sorted().first ?? 1
        if mode == .week {
            let year = Calendar.current.component(.year, from: firstDayOfWeekMode)
            let month = Calendar.current.component(.month, from: firstDayOfWeekMode)
            let day = Calendar.current.component(.day, from: firstDayOfWeekMode)
            if year == currentYear && month == currentMonth {
                return Date.from(year: year, month: month, day: day)
            } else {
                return Date.from(year: currentYear, month: currentMonth, day: day)
            }
        } else {
            return Date.from(year: currentYear, month: currentMonth, day: 1)
        }
    }
}

extension CalendarCollectionView: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureVisibleCellWith(cell: cell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: String(describing: CalendarCollectionCell.self), for: indexPath) as! CalendarCollectionCell
        configureVisibleCellWith(cell: cell, cellState: cellState, date: date)
        handleCellSelectionWith(cell: cell, cellState: cellState)
        return cell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let currentYear = Calendar.current.component(.year, from: Date())
        let startDate = Date.from(year: 2019, month: 1, day: 1)
        let endDate = Date.from(year: currentYear + 1, month: 12, day: 31)
        switch mode {
        case .week:
            return ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 1, generateInDates: .forFirstMonthOnly, generateOutDates: .off)
        case .month:
            return ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 6)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        dateChanged(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelectionWith(cell: cell, cellState: cellState)
        calendarCollectionViewDelegate?.didSelectDate(date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelectionWith(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        return cellState.dateBelongsTo == .thisMonth
    }
}
