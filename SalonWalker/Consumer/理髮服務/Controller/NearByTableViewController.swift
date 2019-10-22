//
//  NearByTableViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import CoreLocation

protocol NearByTableViewControllerDelegate: class {
    func didSelectDesigner(at indexPath: IndexPath, coordinate: CLLocationCoordinate2D)
    func tableViewWillDisplayCellAt(_ indexPath: IndexPath)
}

class NearByTableViewController: BaseViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    weak var delegate: NearByTableViewControllerDelegate?
    
    private var designerListArray: [DesignerListModel] = []
    private var selectIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Method
    func reloadData(_ designerListArray: [DesignerListModel], defaultSelect: Bool) {
        self.designerListArray = designerListArray
        self.tableView.reloadData()
        
        // 預設選第一個
        if defaultSelect && self.designerListArray.count != 0 {
            self.selectRowAt(IndexPath(row: 0, section: 0))
        }
    }
    
    func scrollToIndexPath(_ indexPath: IndexPath) {
        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        self.selectRowAt(indexPath)
    }
    
    private func selectRowAt(_ indexPath: IndexPath) {
        if let selectIndexPath = selectIndexPath {
            self.tableView(self.tableView, didDeselectRowAt: selectIndexPath)
        }
        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        self.tableView(self.tableView, didSelectRowAt: indexPath)
    }
    
    private func changeCellLayerColorWith(cell: UITableViewCell, indexPath: IndexPath) {
        if let selectIndexPath = selectIndexPath, selectIndexPath.row == indexPath.row {
            cell.contentView.layer.borderColor = color_0087FF.cgColor
        } else {
            cell.contentView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}

extension NearByTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return designerListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NearByTableViewCell.self), for: indexPath) as! NearByTableViewCell
        cell.layoutIfNeeded()
        cell.setupCellWithModel(self.designerListArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if SizeTool.isIphoneX() {
            return screenHeight * 0.095
        }
        return screenHeight * 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectIndexPath = indexPath
        if let cell = tableView.cellForRow(at: indexPath) {
            changeCellLayerColorWith(cell: cell, indexPath: indexPath)
        }
        let model = self.designerListArray[indexPath.row]
        let coordinate = CLLocationCoordinate2D(latitude: model.lat, longitude: model.lng)
        self.delegate?.didSelectDesigner(at: indexPath, coordinate: coordinate)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.selectIndexPath = nil
        if let cell = tableView.cellForRow(at: indexPath) {
            changeCellLayerColorWith(cell: cell, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        changeCellLayerColorWith(cell: cell, indexPath: indexPath)
        self.delegate?.tableViewWillDisplayCellAt(indexPath)
    }
    
}

