//
//  StoreShowSchemeTableViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/15.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol StoreShowSchemeTableViewCellDelegate: class {
    func didSelectWeek(with selectIndexArray: [Int], at indexPath: IndexPath)
    func deleteButtonPressAt(indexPath: IndexPath)
    func textFieldEditingChange(indexPath: IndexPath, price: Int?)
}

class StoreShowSchemeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var unitLabel: IBInspectableLabel!
    @IBOutlet weak var headerLabel: IBInspectableLabel!
    
    private var weekArray: [String] = [LocalizedString("Lang_GE_035"),
                                       LocalizedString("Lang_GE_029"),
                                       LocalizedString("Lang_GE_030"),
                                       LocalizedString("Lang_GE_031"),
                                       LocalizedString("Lang_GE_032"),
                                       LocalizedString("Lang_GE_033"),
                                       LocalizedString("Lang_GE_034")]
    private var selectIndexArray: [Int] = []
    private var indexPath: IndexPath?
    private weak var delegate: StoreShowSchemeTableViewCellDelegate?
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Event Handler
    @IBAction func deleteButtonClick(_ sender: UIButton) {
        
        if let indexPath = indexPath {
            self.delegate?.deleteButtonPressAt(indexPath: indexPath)
        }
    }
    
    @IBAction func dayButtonClick(_ sender: UIButton) {
        PresentationTool.showTableViewWith(itemArray: weekArray, selectIndexArray: selectIndexArray, confirmAction: { [unowned self] (indexArray) in
            self.setupDayLabel(indexArray)
            if let indexPath = self.indexPath {
                self.delegate?.didSelectWeek(with: indexArray, at: indexPath)
            }
        })
    }
    
    // MARK: Method
    func setupCellWith(model: WorkTimeModel, type: PaySchemeType, indexPath: IndexPath, delegate: StoreShowSchemeTableViewCellDelegate) {
        self.indexPath = indexPath
        self.delegate = delegate
        self.headerLabel.text = "\(LocalizedString("Lang_AC_057"))(\(indexPath.row + 1))"
        self.unitLabel.text = (type == .hour) ? LocalizedString("Lang_PS_009") : LocalizedString("Lang_PS_010")
        self.setupDayLabel(model.weekIndex)
        
        if let price = model.price {
            self.priceTextField.text = String(price)
        } else {
            self.priceTextField.text = nil
        }
    }
    
    private func setupDayLabel(_ array: [Int]?) {
        if let selectWeek = array, selectWeek.count > 0 {
            self.selectIndexArray = selectWeek
            var text = ""
            for week in selectWeek {
                text.append((text.count == 0) ? weekArray[week] : "、\(weekArray[week])")
            }
            self.dayLabel.text = text
            self.dayLabel.textColor = .black
        } else {
            self.selectIndexArray = []
            self.dayLabel.text = LocalizedString("Lang_AC_047")
            self.dayLabel.textColor = color_C6C6C6
        }
    }
}

extension StoreShowSchemeTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let totalString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if let totalString = totalString {
            if totalString.count > 6 {
                return false
            } else {
                if let indexPath = indexPath {
                    self.delegate?.textFieldEditingChange(indexPath: indexPath, price: Int(totalString))
                }
            }
        }
        return true
    }
}
