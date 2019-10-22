//
//  ExtensionUILabel.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/3.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

extension UILabel {
    // 參考網址：https://stackoverflow.com/a/42592553/7103908
    func setLineSpacing(lineSpacing: CGFloat = 0.0) {
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
        let attributedString = (self.attributedText != nil) ? NSMutableAttributedString(attributedString: self.attributedText!) : NSMutableAttributedString(string: labelText)
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }
}
