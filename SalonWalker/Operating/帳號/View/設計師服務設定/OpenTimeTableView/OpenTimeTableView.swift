//
//  OpenTimeTableView.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/25.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum OpenTimeTableViewCellType {
    case designerOpenTime   //設計師_服務設定_開放時間：時間表
    case providerOpenTime   //場地_服務設定_營業時段
}

protocol OpenTimeTableViewDelegate: class {
    func addWorkTime()
    func didChangeWorkTime(with model: WorkTimeModel, at indexPath: IndexPath)
    func deleteWorkTimeAt(indexPath: IndexPath)
}

class OpenTimeTableView: UITableView {

    private var workTimeArray: [WorkTimeModel] = []
    private var cellType: OpenTimeTableViewCellType = .designerOpenTime
    private weak var openTimeTableViewDelegate: OpenTimeTableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.dataSource = self
        self.register(UINib(nibName: "OpenTimeTableViewCell", bundle: nil), forCellReuseIdentifier: "OpenTimeTableViewCell")
    }
    
    func setupTableViewWith(workTimeArray: [WorkTimeModel], cellType: OpenTimeTableViewCellType, delegate: OpenTimeTableViewDelegate) {
        self.workTimeArray = workTimeArray
        self.cellType = cellType
        self.openTimeTableViewDelegate = delegate
    }
    
    func reloadDataWith(workTimeArray: [WorkTimeModel]) {
        self.workTimeArray = workTimeArray
        self.reloadData()
    }
}

extension OpenTimeTableView: UITableViewDelegate ,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workTimeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenTimeTableViewCell", for: indexPath) as! OpenTimeTableViewCell
        cell.setupCellWith(model: workTimeArray[indexPath.row], cellType: cellType, indexPath: indexPath, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
        /* 已詢問 Catherine 增加欄位上限暫定為 30 個 , By Scott 2018/06/21 */
        if workTimeArray.count  < 30 {
            let imageView = UIImageView(frame: CGRect(x: screenWidth - 30, y: 15, width: 13, height: 13))
            let addButton = UIButton(frame: CGRect(x: screenWidth - 45, y: 0, width: 45, height: 50))
            addButton.addTarget(self, action: #selector(addButtonClick(_:)), for: .touchUpInside)
            imageView.image = UIImage(named: "ic_items_add")
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            footerView.addSubview(imageView)
            footerView.addSubview(addButton)
        }
        return footerView
    }
    
    @objc func addButtonClick(_ sender: UIButton) {
        workTimeArray.append(WorkTimeModel(weekIndex: nil, from: nil, end: nil, price: nil))
        self.openTimeTableViewDelegate?.addWorkTime()
        self.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
            self.scrollToRow(at: IndexPath(row: self.workTimeArray.count - 1, section: 0), at: .none, animated: true)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
}

extension OpenTimeTableView: OpenTimeTableViewCellDelegate {
    func didSelectWeek(with selectIndexArray: [Int], at indexPath: IndexPath) {
        self.workTimeArray[indexPath.row].weekIndex = selectIndexArray
        self.openTimeTableViewDelegate?.didChangeWorkTime(with: workTimeArray[indexPath.row], at: indexPath)
    }
    
    func didSelectStartTime(with startTime: String, at indexPath: IndexPath) {
        self.workTimeArray[indexPath.row].from = startTime
        self.openTimeTableViewDelegate?.didChangeWorkTime(with: workTimeArray[indexPath.row], at: indexPath)
    }
    
    func didSelectEndTim(with endTime: String, at indexPath: IndexPath) {
        self.workTimeArray[indexPath.row].end = endTime
        self.openTimeTableViewDelegate?.didChangeWorkTime(with: workTimeArray[indexPath.row], at: indexPath)
    }
    
    func deleteButtonPressAt(indexPath: IndexPath) {
        let model = self.workTimeArray[indexPath.row]
        if model.weekIndex != nil ||
            model.from != nil ||
            model.end != nil {
            PresentationTool.showTwoButtonAlertWith(image: UIImage(named: "img_time_delete"), message: LocalizedString("Lang_AC_049"), leftButtonTitle: LocalizedString("Lang_GE_060"), leftButtonAction: nil, rightButtonTitle: LocalizedString("Lang_AC_048")) {
                self.workTimeArray.remove(at: indexPath.row)
                self.reloadData()
                self.openTimeTableViewDelegate?.deleteWorkTimeAt(indexPath: indexPath)
            }
        } else {
            self.workTimeArray.remove(at: indexPath.row)
            self.reloadData()
            self.openTimeTableViewDelegate?.deleteWorkTimeAt(indexPath: indexPath)
        }
    }
}
