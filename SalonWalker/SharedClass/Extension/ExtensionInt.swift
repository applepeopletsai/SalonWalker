//
//  ExtensionInt.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/14.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

extension Int {
    func transferToWeekString() -> String {
        switch self {
        case 0: return LocalizedString("Lang_GE_035")
        case 1: return LocalizedString("Lang_GE_029")
        case 2: return LocalizedString("Lang_GE_030")
        case 3: return LocalizedString("Lang_GE_031")
        case 4: return LocalizedString("Lang_GE_032")
        case 5: return LocalizedString("Lang_GE_033")
        case 6: return LocalizedString("Lang_GE_034")
        default: return ""
        }
    }
    
    func transferToMonthString() -> String {
        switch self {
        case 1: return LocalizedString("Lang_GE_044")
        case 2: return LocalizedString("Lang_GE_045")
        case 3: return LocalizedString("Lang_GE_046")
        case 4: return LocalizedString("Lang_GE_047")
        case 5: return LocalizedString("Lang_GE_048")
        case 6: return LocalizedString("Lang_GE_049")
        case 7: return LocalizedString("Lang_GE_050")
        case 8: return LocalizedString("Lang_GE_051")
        case 9: return LocalizedString("Lang_GE_052")
        case 10: return LocalizedString("Lang_GE_053")
        case 11: return LocalizedString("Lang_GE_054")
        case 12: return LocalizedString("Lang_GE_055")
        default: return ""
        }
    }
    
    func transferToDecimalString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
