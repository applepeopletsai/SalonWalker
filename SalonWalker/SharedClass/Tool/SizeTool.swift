//
//  SizeTool.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/23.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

let screenSize = UIScreen.main.bounds.size
let screenWidth = screenSize.width
let screenHeight = screenSize.height

class SizeTool {
    static let sharedInstance = SizeTool()
    
    private let is_iPad: Bool = (UIDevice.current.userInterfaceIdiom == .pad)
    private let is_iPhone: Bool = (UIDevice.current.userInterfaceIdiom == .phone)
    private let is_retina: Bool = (UIScreen.main.scale >= 2.0)
    
    private let screenMaxLength = max(screenWidth, screenHeight)
//    private let screenMinLength = min(screenWidth, screenHeight)
    
    private var is_iPhone4OrLess: Bool { return (is_iPhone && screenMaxLength < 568.0) }
    private var is_iPhone5: Bool { return (is_iPhone && screenMaxLength == 568.0) }
    private var is_iPhone6: Bool { return (is_iPhone && screenMaxLength == 667.0) }
    private var is_iPhone6Plus: Bool { return (is_iPhone && screenMaxLength == 736.0) }
    private var is_iPhoneX: Bool { return (is_iPhone && screenMaxLength == 812.0) }
    private var is_iPad_Pro: Bool { return (is_iPad && screenMaxLength == 1366.0) }
    
    static func isIphone4OrLess() -> Bool {
        return SizeTool.sharedInstance.is_iPhone4OrLess
    }
    
    static func isIphone5() -> Bool {
        return SizeTool.sharedInstance.is_iPhone5
    }
    
    static func isIphone6() -> Bool {
        return SizeTool.sharedInstance.is_iPhone6
    }
    
    static func isIphone6Plus() -> Bool {
        return SizeTool.sharedInstance.is_iPhone6Plus
    }
    
    static func isIphoneX() -> Bool {
        return SizeTool.sharedInstance.is_iPhoneX
    }
}
