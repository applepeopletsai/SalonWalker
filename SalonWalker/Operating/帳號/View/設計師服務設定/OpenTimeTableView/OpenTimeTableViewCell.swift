//
//  OpenTimeTableViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/11.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol OpenTimeTableViewCellDelegate: class {
    func didSelectWeek(with selectIndexArray: [Int], at indexPath: IndexPath)
    func didSelectStartTime(with startTime: String, at indexPath: IndexPath)
    func didSelectEndTim(with endTime: String, at indexPath: IndexPath)
    func deleteButtonPressAt(indexPath: IndexPath)
}

class OpenTimeTableViewCell: UITableViewCell {

    @IBOutlet weak var uiLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var uiTrallingSpace: NSLayoutConstraint!
    @IBOutlet weak var startTimeLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var endTimeLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var headerLabel: IBInspectableLabel!
    @IBOutlet weak var dayLabel: IBInspectableLabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    private var weekArray: [String] = [LocalizedString("Lang_GE_035"),
                                       LocalizedString("Lang_GE_029"),
                                       LocalizedString("Lang_GE_030"),
                                       LocalizedString("Lang_GE_031"),
                                       LocalizedString("Lang_GE_032"),
                                       LocalizedString("Lang_GE_033"),
                                       LocalizedString("Lang_GE_034")]
    private var timeArray: [String] {
        var array: [String] = []
        var hourString = ""
        let minuteArray: [String] = ["00","10","20","30","40","50"]
        for hour in 8...23 {
            hourString = (hour < 10) ? "0\(hour)" : "\(hour)"
            for minute in minuteArray {
                array.append(String(hourString + ":" + minute))
            }
        }
        return array
    }
    private var workTimeModel: WorkTimeModel?
    private var indexPath: IndexPath?
    private weak var delegate: OpenTimeTableViewCellDelegate?
    
    // MARK: Lifr Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        changeLayoutContraint()
    }
    
    // MARK: Method
    func setupCellWith(model: WorkTimeModel, cellType: OpenTimeTableViewCellType, indexPath: IndexPath, delegate: OpenTimeTableViewCellDelegate) {
        self.workTimeModel = model
        self.indexPath = indexPath
        self.delegate = delegate
        self.headerLabel.text = (cellType == .designerOpenTime) ?
            (String(LocalizedString("Lang_DD_004") + "(" + "\(indexPath.row + 1)" + ")")) :
            (String(LocalizedString("Lang_HM_011") + "(" + "\(indexPath.row + 1)" + ")"))
        self.setupWeekAndTimeLabelText()
    }
    
    private func changeLayoutContraint() {
        if SizeTool.isIphone5() {
            uiLeadingSpace.constant = 15
            uiTrallingSpace.constant = 15
        }
        if SizeTool.isIphone6() || SizeTool.isIphoneX() {
            startTimeLeadingSpace.constant = 20
            endTimeLeadingSpace.constant = 20
        }
        if SizeTool.isIphone6Plus() {
            startTimeLeadingSpace.constant = 30
            endTimeLeadingSpace.constant = 30
        }
    }
    
    private func setupWeekAndTimeLabelText() {
        if let weekIndex = workTimeModel?.weekIndex, weekIndex.count > 0 {
            var week = ""
            for index in weekIndex {
                week.append((week.count == 0) ? weekArray[index] : "、\(weekArray[index])")
            }
            self.dayLabel.text = week
            self.dayLabel.textColor = .black
        } else {
            self.dayLabel.text = LocalizedString("Lang_AC_047")
            self.dayLabel.textColor = color_C6C6C6
        }
        if let from = workTimeModel?.from {
            self.startTimeLabel.text = from
            self.startTimeLabel.textColor = .black
        } else {
            self.startTimeLabel.text = "00:00"
            self.startTimeLabel.textColor = color_C6C6C6
        }
        if let end = workTimeModel?.end {
            self.endTimeLabel.text = end
            self.endTimeLabel.textColor = .black
        } else {
            self.endTimeLabel.text = "00:00"
            self.endTimeLabel.textColor = color_C6C6C6
        }
    }
    
    // MARK: EventHandler
    @IBAction func dayButtonClick(_ sender: UIButton) {
        let selectIndex = workTimeModel?.weekIndex ?? []
        PresentationTool.showTableViewWith(itemArray: weekArray, selectIndexArray: selectIndex, confirmAction: { [unowned self] (indexArray) in
            self.workTimeModel?.weekIndex = indexArray
            self.delegate?.didSelectWeek(with: indexArray, at: self.indexPath!)
            self.setupWeekAndTimeLabelText()
        })
    }
    
    @IBAction func startButtonClick(_ sender: UIButton) {
        let selectIndex = self.timeArray.index(of: workTimeModel?.from ?? "") ?? 0
        PresentationTool.showPickerWith(itemArray: timeArray, selectedIndex: selectIndex, cancelAction: nil, confirmAction: { [unowned self] (item, index) in
            if let end = self.workTimeModel?.end {
                let endIndex = self.timeArray.index(of: end) ?? 0
                if index < endIndex {
                    self.workTimeModel?.from = item
                    self.setupWeekAndTimeLabelText()
                    self.delegate?.didSelectStartTime(with: item, at: self.indexPath!)
                } else {
                    SystemManager.showWarningBanner(title: LocalizedString("Lang_AC_050"), body: "")
                }
            } else {
                self.workTimeModel?.from = item
                self.setupWeekAndTimeLabelText()
                self.delegate?.didSelectStartTime(with: item, at: self.indexPath!)
            }
        })
    }
    
    @IBAction func endButtonClick(_ sender: UIButton) {
        let selectIndex = self.timeArray.index(of: workTimeModel?.end ?? "") ?? 0
        PresentationTool.showPickerWith(itemArray: timeArray, selectedIndex: selectIndex, cancelAction: nil, confirmAction: { [unowned self] (item, index) in
            if let start = self.workTimeModel?.from {
                let startIndex = self.timeArray.index(of: start) ?? 0
                if index > startIndex {
                    self.workTimeModel?.end = item
                    self.setupWeekAndTimeLabelText()
                    self.delegate?.didSelectEndTim(with: item, at: self.indexPath!)
                } else {
                    SystemManager.showWarningBanner(title: LocalizedString("Lang_AC_051"), body: "")
                }
            } else {
                self.workTimeModel?.end = item
                self.setupWeekAndTimeLabelText()
                self.delegate?.didSelectEndTim(with: item, at: self.indexPath!)
            }
        })
    }
    
    @IBAction func deleteButtonClick(_ sender: UIButton) {
        self.delegate?.deleteButtonPressAt(indexPath: self.indexPath!)
    }
}
