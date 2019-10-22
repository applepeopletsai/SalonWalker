//
//  StoreShowRentSchemeTableViewCell.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/16.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol StoreShowRentSchemeTableViewCellDelegate: class {
    func deleteButtonClickAt(_ indexPath: IndexPath)
    func didSelectStartDate(at indexPath: IndexPath, with startDate: String)
    func didSelectEndDate(at indexPath: IndexPath, with endDate: String)
    func textFieldEditingChange(at indexPath: IndexPath, with price: Int?)
}

class StoreShowRentSchemeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var headerLabelLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var deleteImageTrallingSpace: NSLayoutConstraint!
    @IBOutlet weak var headerLabel: IBInspectableLabel!

    private var indexPath: IndexPath?
    private weak var delegate: StoreShowRentSchemeTableViewCellDelegate?
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        changeLayoutConstraint()
    }
    
    // MARK: Method
    func setupCellWith(model: LongLeasePricesModel, indexPath: IndexPath, delegate: StoreShowRentSchemeTableViewCellDelegate) {
        self.indexPath = indexPath
        self.delegate = delegate
        
        self.headerLabel.text = "\(LocalizedString("Lang_AC_057"))(\(indexPath.row + 1))"
        if let startDay = model.startDay {
            self.startDateLabel.text = startDay
            self.startDateLabel.textColor = .black
        } else {
            self.startDateLabel.text = LocalizedString("Lang_PS_012")
            self.startDateLabel.textColor = color_C6C6C6
        }
        if let endDay = model.endDay {
            self.endDateLabel.text = endDay
            self.endDateLabel.textColor = .black
        } else {
            self.endDateLabel.text = LocalizedString("Lang_PS_012")
            self.endDateLabel.textColor = color_C6C6C6
        }
        if let prices = model.prices {
            self.priceTextField.text = String(prices)
        } else {
            self.priceTextField.text = nil
        }
    }
    
    private func changeLayoutConstraint() {
        if SizeTool.isIphone5() {
            headerLabelLeadingSpace.constant = 15
            deleteImageTrallingSpace.constant = 15
            startDateLabel.font = UIFont.systemFont(ofSize: 16)
            endDateLabel.font = UIFont.systemFont(ofSize: 16)
        }
    }
    
    // MARK: Event Handler
    @IBAction func startDateButtonClick(_ sender: UIButton) {
        PresentationTool.showCalendarWith(shouldNotSelectDayArray: nil, cancelAction: nil, confirmAction: { [unowned self] (date) in
            let dateString = date.transferToString(dateFormat: "yyyy-MM-dd")
            self.startDateLabel.text = dateString
            self.startDateLabel.textColor = UIColor.black
            if let indexPath = self.indexPath {
                self.delegate?.didSelectStartDate(at: indexPath, with: dateString)
            }
        })
    }
    
    @IBAction func endDateButtonClick(_ sender: UIButton) {
        PresentationTool.showCalendarWith(shouldNotSelectDayArray: nil, cancelAction: nil, confirmAction: { [unowned self] (date) in
            let dateString = date.transferToString(dateFormat: "yyyy-MM-dd")
            self.endDateLabel.text = dateString
            self.endDateLabel.textColor = UIColor.black
            if let indexPath = self.indexPath {
                self.delegate?.didSelectEndDate(at: indexPath, with: dateString)
            }
        })
    }
    
    @IBAction func deleteButtonClick(_ sender: UIButton) {
        
        if let indexPath = self.indexPath {
            self.delegate?.deleteButtonClickAt(indexPath)
        }
    }
}

extension StoreShowRentSchemeTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let totalString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if let totalString = totalString {
            if totalString.count > 6 {
                return false
            } else {
                if let indexPath = indexPath {
                    self.delegate?.textFieldEditingChange(at: indexPath, with: Int(totalString))
                }
            }
        }
        return true
    }
}
