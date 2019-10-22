//
//  CalendarViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/27.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import JTAppleCalendar

typealias calendarConfirmHandler = (_ date: Date) -> Void

class ShareCalendarViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var calendarView: JTAppleCalendarView!
    
    private var cancelAction: actionClosure?
    private var confirmAction: calendarConfirmHandler?
    private var shouldNotSelectDayArray: [Date]?
    private var canSelectDayArray = [Date]()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToCurrentDate()
    }
    
    // MARK: Method
    func setupVCWith(shouldNotSelectDayArray: [Date]?, cancelAction:actionClosure?, confirmAction: @escaping calendarConfirmHandler) {
        self.cancelAction = cancelAction
        self.confirmAction = confirmAction
        self.shouldNotSelectDayArray = shouldNotSelectDayArray
    }
    
    func setupVCWith(canSelectDayArray: [Date], cancelAction:actionClosure?, confirmAction: @escaping calendarConfirmHandler) {
        self.cancelAction = cancelAction
        self.confirmAction = confirmAction
        self.canSelectDayArray = canSelectDayArray
    }
    
    private func scrollToCurrentDate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
            if self.canSelectDayArray.count > 0 {
                self.calendarView.scrollToDate(self.canSelectDayArray.first!)
            } else {
                self.calendarView.scrollToDate(Date())
            }
        })
    }
    
    private func setupCalendar() {
        calendarView.visibleDates { [unowned self] (visibleDates: DateSegmentInfo) in
            self.setupTitleOfCalendar(from: visibleDates)
        }
        calendarView.minimumInteritemSpacing = 3
    }
    
    private func setupTitleOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let month = Calendar.current.dateComponents([.month], from: startDate).month!
//        let monthName = DateFormatter().monthSymbols[(month-1) % 12]
        // 0 indexed array
        let year = Calendar.current.component(.year, from: startDate)
        titleLabel.text = "\(month)\(LocalizedString("Lang_GE_061")) \(year)"
    }
    
    private func configureVisibleCellWith(cell: JTAppleCell, cellState: CellState, date: Date) {
        guard let cell = cell as? CalendarCell  else { return }
        if cellState.dateBelongsTo == .thisMonth {
            cell.isHidden = false
        } else {
            cell.isHidden = true
            return
        }
        
        cell.dayLabel.text = cellState.text
        cell.layer.cornerRadius = cell.frame.size.width * 0.5
    }
    
    private func handleCellSelectionWith(cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
//        if calendarView.allowsMultipleSelection {
//            switch cellState.selectedPosition() {
//            case .full: view.backgroundColor = .green
//            case .left: view.backgroundColor = .yellow
//            case .right: view.backgroundColor = .red
//            case .middle: view.backgroundColor = .blue
//            case .none: view.backgroundColor = .white
//            }
//        } else
//        {
        
            if dateSelectable(cellState.date) {
                if cellState.isSelected {
                    cell.backgroundColor = color_1A1C69
                    cell.dayLabel.textColor = UIColor.white
                } else {
                    cell.backgroundColor = UIColor.white
                    cell.dayLabel.textColor = color_1A1C69
                }
            } else {
                cell.backgroundColor = UIColor.white
                cell.dayLabel.textColor = color_9B9B9B
            }
        
//        }
    }
    
    private func dateSelectable(_ date: Date) -> Bool {
        if canSelectDayArray.count > 0 {
            for canSelectDate in canSelectDayArray {
                if canSelectDate == date {
                    return true
                }
            }
            return false
        } else {
            guard let shouldNotSelectDayArray = shouldNotSelectDayArray, shouldNotSelectDayArray.count != 0 else {
                return true
            }
            
            for shouldNotSelectDay in shouldNotSelectDayArray {
                if date == shouldNotSelectDay {
                    return false
                }
            }
            return true
        }
    }
    
    // MARK: Event Handler
    @IBAction private func previousButtonPress(_ sender: UIButton) {
        calendarView.scrollToSegment(.previous)
    }
    
    @IBAction private func nextButtonPress(_ sender: UIButton) {
        calendarView.scrollToSegment(.next)
    }
    
    @IBAction private func cancelButtonPress(_ sender: UIButton) {
        cancelAction?()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func confirmButtonPress(_ sender: UIButton) {
        if let date = calendarView.selectedDates.last {
            confirmAction?(date)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension ShareCalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureVisibleCellWith(cell: cell, cellState: cellState, date: date)
        handleCellSelectionWith(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: String(describing: CalendarCell.self), for: indexPath) as! CalendarCell
        configureVisibleCellWith(cell: cell, cellState: cellState, date: date)
        handleCellSelectionWith(cell: cell, cellState: cellState)
        return cell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let currentYear = Calendar.current.component(.year, from: Date())
        let startDate = Date.from(year: currentYear, month: 1, day: 1)
        let endDate = Date.from(year: currentYear + 5, month: 12, day: 31)
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupTitleOfCalendar(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelectionWith(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelectionWith(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        return dateSelectable(date)
    }
}
