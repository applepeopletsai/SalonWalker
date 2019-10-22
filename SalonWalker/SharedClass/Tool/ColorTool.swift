//
//  ColorTool.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/21.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

let color_FF5A00 = ColorTool.colorWith(hexString: "#FF5A00", alpha: 1.0)
let color_EEEEEE = ColorTool.colorWith(hexString: "#EEEEEE", alpha: 1.0)
let color_8F92F5 = ColorTool.colorWith(hexString: "#8F92F5", alpha: 1.0)
let color_979797 = ColorTool.colorWith(hexString: "#979797", alpha: 1.0)
let color_1A1C69 = ColorTool.colorWith(hexString: "#1A1C69", alpha: 1.0)
let color_E1FFF4 = ColorTool.colorWith(hexString: "#E1FFF4", alpha: 1.0)
let color_EEE9FE = ColorTool.colorWith(hexString: "#EEE9FE", alpha: 1.0)
let color_9B9B9B = ColorTool.colorWith(hexString: "#9B9B9B", alpha: 1.0)
let color_3DF9B1 = ColorTool.colorWith(hexString: "#3DF9B1", alpha: 1.0)
let color_2F10A0 = ColorTool.colorWith(hexString: "#2F10A0", alpha: 1.0)
let color_0087FF = ColorTool.colorWith(hexString: "#0087FF", alpha: 1.0)
let color_F2F2F2 = ColorTool.colorWith(hexString: "#F2F2F2", alpha: 1.0)
let color_B3B3B3 = ColorTool.colorWith(hexString: "#B3B3B3", alpha: 1.0)
let color_AAAAAA = ColorTool.colorWith(hexString: "#AAAAAA", alpha: 1.0)
let color_C7C7CD = ColorTool.colorWith(hexString: "#C7C7CD", alpha: 1.0)
let color_7AFEC6 = ColorTool.colorWith(hexString: "#7AFEC6", alpha: 1.0)
let color_C6C6C6 = ColorTool.colorWith(hexString: "#C6C6C6", alpha: 1.0)
let color_D8D8D8 = ColorTool.colorWith(hexString: "#D8D8D8", alpha: 1.0)
let color_F8F6FF = ColorTool.colorWith(hexString: "#F8F6FF", alpha: 1.0)
let color_595968 = ColorTool.colorWith(hexString: "#595968", alpha: 1.0)
let color_B7B9F4 = ColorTool.colorWith(hexString: "#B7B9F4", alpha: 1.0)
let color_4A4A4A = ColorTool.colorWith(hexString: "#4A4A4A", alpha: 1.0)
let color_F1F1F1 = ColorTool.colorWith(hexString: "#F1F1F1", alpha: 1.0)
let color_7A57FA = ColorTool.colorWith(hexString: "#7A57FA", alpha: 0.13)

class ColorTool: NSObject {
    static func colorWith(hexString: String, alpha: CGFloat) -> UIColor {
        let colorString = hexString.replacingOccurrences(of: "#", with: "").uppercased()
        
        var red: CGFloat = 0, blue: CGFloat = 0, green: CGFloat = 0
        switch colorString.count {
        case 3: // #RGB
            red   = self.colorComponetFromWith(string: colorString, start: 0, length: 1)
            green = self.colorComponetFromWith(string: colorString, start: 1, length: 1)
            blue  = self.colorComponetFromWith(string: colorString, start: 2, length: 1)
            break
        case 4: // #ARGB
            red   = self.colorComponetFromWith(string: colorString, start: 1, length: 1)
            green = self.colorComponetFromWith(string: colorString, start: 2, length: 1)
            blue  = self.colorComponetFromWith(string: colorString, start: 3, length: 1)
            break
        case 6: // #RRGGBB
            red   = self.colorComponetFromWith(string: colorString, start: 0, length: 2)
            green = self.colorComponetFromWith(string: colorString, start: 2, length: 2)
            blue  = self.colorComponetFromWith(string: colorString, start: 4, length: 2)
            break
        case 8: // #AARRGGBB
            red   = self.colorComponetFromWith(string: colorString, start: 2, length: 2)
            green = self.colorComponetFromWith(string: colorString, start: 4, length: 2)
            blue  = self.colorComponetFromWith(string: colorString, start: 6, length: 2)
            break
        default:
            var error: NSError?
            error = nil
            NSException.raise(NSExceptionName(rawValue: "Invalid color value"), format: "Color value \(hexString) is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB. Error: %@", arguments: getVaList([error ?? "nil"]))
            break
        }
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    private static func colorComponetFromWith(string: String, start: Int, length: Int) -> CGFloat {
        let range = string.index(string.startIndex, offsetBy: start)..<string.index(string.startIndex, offsetBy: start+length)
        let subString = String(string[range])
        let fullHex = length == 2 ? subString : "\(subString)\(subString)"
        let hexComponet = Int(fullHex, radix: 16)!
        return CGFloat(Float(hexComponet) / 255.0)
    }
    
    static func createImageWithColor(_ color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let theImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return theImage
    }
}
