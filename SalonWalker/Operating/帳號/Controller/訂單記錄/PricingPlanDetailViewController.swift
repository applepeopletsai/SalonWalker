//
//  PricingPlanDetailViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/12.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class PricingPlanDetailViewController: BaseViewController {

    @IBOutlet private weak var unitLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    
    private var svcHours: HoursAndTimesPricesModel?
    private var svcTimes: HoursAndTimesPricesModel?
    private var svcLongLease: LongLeasePricesModel?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    // MARK: Method
    func setupVCWith(svcHours: HoursAndTimesPricesModel?, svcTimes: HoursAndTimesPricesModel?, svcLongLease: LongLeasePricesModel?) {
        self.svcHours = svcHours
        self.svcTimes = svcTimes
        self.svcLongLease = svcLongLease
    }
    
    private func initialize() {
        if let svcHours = svcHours {
            self.dateLabel.text = svcHours.weekDay.transferToWeekString()
            self.priceLabel.text = "$\(svcHours.prices.transferToDecimalString())"
            self.unitLabel.text = LocalizedString("Lang_PS_009")
        }
        if let svcTimes = svcTimes {
            self.dateLabel.text = svcTimes.weekDay.transferToWeekString()
            self.priceLabel.text = "$\(svcTimes.prices.transferToDecimalString())"
            self.unitLabel.text = LocalizedString("Lang_PS_010")
        }
        if let svcLongLease = svcLongLease {
            self.dateLabel.text = "\(svcLongLease.startDay?.subString(from: 0, to: 9).replacingOccurrences(of: "-", with: "/") ?? "") \(LocalizedString("Lang_DD_012")) \(svcLongLease.endDay?.subString(from: 0, to: 9).replacingOccurrences(of: "-", with: "/") ?? "")"
            self.priceLabel.text = "$\(svcLongLease.prices?.transferToDecimalString() ?? "0")"
            self.unitLabel.isHidden = true
        }
    }
}
