//
//  CalendarView.swift
//  CalendarTest
//
//  Created by Daniel on 2018/2/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import JTAppleCalendar

private let cellIdentifier = String(describing: CalendarCell.self)
private let margin: CGFloat = 3.0

protocol CalendarViewDelegate: class {
    func didSelectDate(_ date: Date)
}

class CalendarView: UIView {

    // MARK: Property
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var calendarView: JTAppleCalendarView!
    private weak var delegate: CalendarViewDelegate?
    
    // MARK: Initialize
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(target: CalendarViewDelegate) {
        self.init(frame: CGRect.zero)
        delegate = target
        let space: CGFloat = 5.0
        let width: CGFloat = screenWidth - 5.0 * 2
        let height: CGFloat = width + space * 6 + margin * 2
        let x = (screenWidth - width) * 0.5
        let y = (screenHeight - height) * 0.5
        let frame = CGRect(x: x, y: y, width: width, height: height)
        setupCalendarViewWithFrame(frame)
    }
   
    // MARK: Life Cycle
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
            self.alpha = 1.0
        }, completion: nil)
    }
    
    // MARK: Method
    static func showCalendarWithTarget(_ target: CalendarViewDelegate) {
        let view = CalendarView.init(target: target)
        SystemManager.topViewController().view.addSubview(view)
    }
    
    private func setupCalendarViewWithFrame(_ frame: CGRect) {
        let view = loadNib()
        view.frame = frame
        view.backgroundColor = .white
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.layer.cornerRadius = 5.0
        addSubview(view)
        self.alpha = 0.0
        self.backgroundColor = UIColor(white: 0, alpha: 0.8)
        
        calendarView.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
            self.setupTitleOfCalendar(from: visibleDates)
        }
        calendarView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
//        calendarView.minimumLineSpacing = 3
        calendarView.minimumInteritemSpacing = 3
    }
    
    private func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    private func handleCellConfigurationWith(cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCell  else { return }
        handleCellTextColorWith(cell: cell, cellState: cellState)
        handleCellSelectionWith(cell: cell, cellState: cellState)
    }
    
    private func handleCellTextColorWith(cell: CalendarCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.isHidden = false
            cell.dayLabel.textColor = UIColor.black
        } else {
            cell.isHidden = true
            cell.dayLabel.textColor = UIColor.gray
        }
    }
    
    private func handleCellSelectionWith(cell: CalendarCell, cellState: CellState) {
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
            if cellState.isSelected {
                cell.layer.cornerRadius = cell.frame.size.width * 0.49
                cell.backgroundColor = UIColor.red
            } else {
                cell.backgroundColor = UIColor.white
            }
//        }
    }
    
    private func setupTitleOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let month = Calendar.current.dateComponents([.month], from: startDate).month!
//        let monthName = DateFormatter().monthSymbols[(month-1) % 12]
        // 0 indexed array
        let year = Calendar.current.component(.year, from: startDate)
//        titleLabel.text = monthName + " " + String(year)
        titleLabel.text = "\(month)月 \(year)"
    }
    
    private func configureVisibleCellWith(cell: CalendarCell, cellState: CellState, date: Date) {
        cell.dayLabel.text = cellState.text
        handleCellConfigurationWith(cell: cell, cellState: cellState)
    }
    
    // MARK: Event Handler
    @IBAction private func previousButtonPress(_ sender: UIButton) {
        calendarView.scrollToSegment(.previous)
    }
    
    @IBAction private func nextButtonPress(_ sender: UIButton) {
        calendarView.scrollToSegment(.next)
    }
    
    @IBAction private func cancelButtonPress(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    @IBAction private func confirmButtonPress(_ sender: UIButton) {
        self.removeFromSuperview()
        if let date = calendarView.selectedDates.last {
            self.delegate?.didSelectDate(date)
        }
    }
}

extension CalendarView: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureVisibleCellWith(cell: cell as! CalendarCell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CalendarCell
        configureVisibleCellWith(cell: cell, cellState: cellState, date: date)
        return cell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2030 02 01")!
        
        // firstDayOfWeek暫時設定saturday
        let parameters = ConfigurationParameters(startDate: startDate,endDate: endDate, firstDayOfWeek: DaysOfWeek.saturday)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupTitleOfCalendar(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellConfigurationWith(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellConfigurationWith(cell: cell, cellState: cellState)
    }
}


