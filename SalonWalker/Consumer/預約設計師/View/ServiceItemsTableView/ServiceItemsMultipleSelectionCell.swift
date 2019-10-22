//
//  ServiceItemsMultipleSelectionCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/10.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol ServiceItemsMultipleSelectionCellDelegate: class {
    func multipleSelectItem(model: SvcClassModel, indexPath: IndexPath)
    func didPressAddButtonAt(_ indexPath: IndexPath)
    func didPressDeleteButtonAt(_ indexPath: IndexPath)
}

class ServiceItemsMultipleSelectionCell: UITableViewCell {

    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    
    private var serviceItemArray = [SvcClassModel]()
    private var selectSvcClass: SvcClassModel?
    private var indexPath: IndexPath?
    private weak var delegate: ServiceItemsMultipleSelectionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWith(serviceItemArray: [SvcClassModel], selectSvcClass: SvcClassModel?, indexPath: IndexPath, delegate: ServiceItemsMultipleSelectionCellDelegate?) {
        self.serviceItemArray = serviceItemArray
        self.selectSvcClass = selectSvcClass
        self.indexPath = indexPath
        self.delegate = delegate
        
        self.addButton.isHidden = (indexPath.row != 0)
        self.deleteButton.isHidden = (indexPath.row == 0)
        
        if let selectSvcClass = selectSvcClass, selectSvcClass.name.count > 0 {
            self.selectSvcClass = selectSvcClass
            if let item = selectSvcClass.svcItems?.first {
                self.contentLabel.text = "\(selectSvcClass.name)/\(item.name) $\(item.price ?? 0)"
            } else {
                self.contentLabel.text = "\(selectSvcClass.name) $\(selectSvcClass.price ?? 0)"
            }
            self.contentLabel.textColor = .black
        } else {
            self.contentLabel.text = LocalizedString("Lang_GE_007")
            self.contentLabel.textColor = color_9B9B9B
        }
    }
    
    @IBAction private func buttonPress(_ sender: UIButton) {
        var itemArray = [String]()
        var selectIndex = 0
        
        for i in 0..<serviceItemArray.count {
            let svcClass = serviceItemArray[i]
            if let svcItem = svcClass.svcItems?.first {
                itemArray.append("\(svcClass.name)/\(svcItem.name) $\(svcItem.price ?? 0)")
            } else {
                itemArray.append("\(svcClass.name) $\(svcClass.price ?? 0)")
            }
            if let selectSvcClass = selectSvcClass {
                if let selectSvcItem = selectSvcClass.svcItems?.first, let svcItem = svcClass.svcItems?.first {
                    if selectSvcClass == svcClass, selectSvcItem == svcItem {
                        selectIndex = i
                    }
                } else {
                    if selectSvcClass == svcClass {
                        selectIndex = i
                    }
                }
            }
        }
        
        PresentationTool.showPickerWith(itemArray: itemArray, selectedIndex: selectIndex, cancelAction: nil, confirmAction: { [unowned self] (item, index) in
            self.contentLabel.text = item
            self.contentLabel.textColor = .black
            
            if let indexPath = self.indexPath {
                self.delegate?.multipleSelectItem(model: self.serviceItemArray[index], indexPath: indexPath)
            }
        })
    }
    
    @IBAction private func addButtonPress(_ sender: UIButton) {
        if let indexPath = indexPath {
            self.delegate?.didPressAddButtonAt(indexPath)
        }
    }
    
    @IBAction private func deleteButtonPress(_ sender: UIButton) {
        if let indexPath = indexPath {
            self.delegate?.didPressDeleteButtonAt(indexPath)
        }
    }

}
