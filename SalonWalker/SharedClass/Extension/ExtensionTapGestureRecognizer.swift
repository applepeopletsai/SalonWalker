//
//  ExtensionTapGestureRecognizer.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

extension UITapGestureRecognizer {
    
    // 參考連結：https://samwize.com/2016/03/04/how-to-create-multiple-tappable-links-in-a-uilabel/
    func didTapSpecificText(text: String, onLabel label: UILabel) -> Bool {
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        if let labelString = (label.attributedText == nil) ? label.text : label.attributedText?.string {
            let range = (labelString as NSString).range(of: text)
            // 調整偵測範圍
            var fixRange = range
            fixRange.location -= 2
            fixRange.length += 4
            return NSLocationInRange(indexOfCharacter, fixRange)
        }
        return false
    }
}
