//
//  ServiceItemsSingleSelectionCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/10.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol ServiceItemsSingleSelectionCellDelegate: class {
    func singleSelectItem(model: SvcClassModel, indexPath: IndexPath)
}

class ServiceItemsSingleSelectionCell: UITableViewCell {

    @IBOutlet private weak var contentLabel: UILabel!
    
    private var serviceItemArray = [SvcClassModel]()
    private var selectSvcClass: SvcClassModel?
    private var indexPath: IndexPath?
    private weak var delegate: ServiceItemsSingleSelectionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWith(serviceItemArray: [SvcClassModel], selectSvcClass: SvcClassModel?, indexPath: IndexPath, delegate: ServiceItemsSingleSelectionCellDelegate?) {
        self.serviceItemArray = serviceItemArray
        self.indexPath = indexPath
        self.delegate = delegate
        
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
                self.delegate?.singleSelectItem(model: self.serviceItemArray[index], indexPath: indexPath)
            }
        })
    }
    

}
