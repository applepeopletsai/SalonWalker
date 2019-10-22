//
//  MyCalendarViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/18.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class MyCalendarViewController: BaseViewController {

    @IBOutlet private weak var yearMonthLabel: UILabel!
    @IBOutlet private weak var calendarView: CalendarCollectionView!
    @IBOutlet private weak var tableView: CalendarTableView!
    @IBOutlet private weak var todayButton: IBInspectableButton!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var calendarHeight: NSLayoutConstraint!
    
    private var isScrollToToday = false
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.scrollToToday()
        }
    }
    
    // MARK: Method
    override func networkDidRecover() {
        scrollToToday()
    }
    
    private func initialize() {
        self.calendarView.calendarCollectionViewDelegate = self
        self.tableView.setupTableViewWith(targetViewcontroller: self, delegate: self)
        let day = Calendar.current.component(.day, from: Date())
        self.todayButton.setTitle("\(LocalizedString("Lang_GE_043")) \(day)", for: .normal)
        self.backButton.isHidden = !(UserManager.sharedInstance.userIdentity == .consumer)
    }
    
    private func scrollToToday() {
        isScrollToToday = true
        calendarView.scrollToDate(Date())
    }
    
    fileprivate func changeCalendarHeight(mode: CalendarMode) {
        let height: CGFloat = (mode == .week) ? 40 : 40 * 6
        self.calendarHeight.constant = height
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: Event Handler
    @IBAction private func todayButtonPress(_ sender: UIButton) {
        scrollToToday()
    }
    
    @IBAction private func yearMonthButtonPress(_ sender: UIButton) {
        PresentationTool.showYearMonthPickerWith(cancelAction: nil) { [unowned self] (month, year) in
            self.calendarView.scrollToDate(Date.from(year: year, month: month, day: 1))
        }
    }
}

extension MyCalendarViewController: CalendarCollectionViewDelegate {
    func visibleDateChanged(startDate: Date, endDate: Date) {
        let month = Calendar.current.component(.month, from: startDate)
        let year = Calendar.current.component(.year, from: startDate)
        yearMonthLabel.text = "\(month.transferToMonthString()) \(year)"
        tableView.clearDisplayData()
        tableView.resetDataWith(startDate: startDate, endDate: endDate)
    }
    
    func didSelectDate(_ date: Date) {
        tableView.reloadDataWithSelectDate(date)
    }
    
    func didChangeMode(_ mode: CalendarMode) {
        changeCalendarHeight(mode: mode)
    }
}

extension MyCalendarViewController: CalendarTableViewDelegate {
    func didUpdateDataWith(startDate: Date, endDate: Date, hasOrderDateArray: [Date]) {
        if isScrollToToday {
            calendarView.selectDates([Date()])
            isScrollToToday = false
        } else {
            if let selectDay = calendarView.selectedDates.first, startDate < selectDay, endDate > selectDay {
                tableView.reloadDataWithSelectDate(selectDay)
            }
        }
        
        // 更新calendar dotview 是否需隱藏
        calendarView.shouldShowDotDate(date: hasOrderDateArray)
    }
}

