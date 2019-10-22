//
//  DynamicLabelView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/14.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum ArrangementType {
    case left, center
}

protocol DynamicLabelViewDelegate: class {
    func didSelectItemsIndex(_ itemsIndex: [Int])
}

private class TagLabel: UILabel {
    
    var selectTextColor: UIColor = .white
    var unSelectTextColor: UIColor = color_1A1C69
    var selectBgColor: UIColor = color_1A1C69
    var unSelectBgColor: UIColor = .white
    
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                self.textColor = selectTextColor
                self.backgroundColor = selectBgColor
            } else {
                self.textColor = unSelectTextColor
                self.backgroundColor = unSelectBgColor
            }
        }
    }
}

class DynamicLabelView: UIView {
    
    private weak var delegate: DynamicLabelViewDelegate?
    private var labelArray: [TagLabel] = []
    private var labelFontSize: CGFloat = 12.0
    private var labelHeight: CGFloat = 25.0
    private var labelSpace: CGFloat = 8.0
    private var selectTextColor: UIColor = .white
    private var unSelectTextColor: UIColor = color_1A1C69
    private var selectBgColor: UIColor = color_1A1C69
    private var unSelectBgColor: UIColor = .white
    private var borderColor: UIColor = color_1A1C69
    private var borderWidth: CGFloat = 1.0
    private var layerCornerRadius: CGFloat? = nil
    private var multipleSelect: Bool = false
    private var selectedIndex: [Int] = []
    private var currentXArray: [CGFloat] = []
    private var arrangementType: ArrangementType = .center
    
//    private var scrollView: UIScrollView = {
//        return UIScrollView(frame: CGRect.zero)
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(frame: CGRect, labelTextArray: [String], target: DynamicLabelViewDelegate, arrangementType: ArrangementType = .center, labelFontSize: CGFloat = 12.0, labelHeight: CGFloat = 25.0, labelSpace: CGFloat = 8.0, selectTextColor: UIColor = .white, unSelectTextColor: UIColor = color_1A1C69, selectBgColor: UIColor = color_1A1C69, unSelectBgColor: UIColor = .white, borderWidth: CGFloat = 1, borderColor: UIColor = color_1A1C69, layerCornerRadius: CGFloat? = nil, multipleSelect: Bool = false) {
        self.init(frame: frame)
        self.arrangementType = arrangementType
        self.labelFontSize = labelFontSize
        self.labelHeight = labelHeight
        self.labelSpace = labelSpace
        self.selectTextColor = selectTextColor
        self.unSelectTextColor = unSelectTextColor
        self.selectBgColor = selectBgColor
        self.unSelectBgColor = unSelectBgColor
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.layerCornerRadius = layerCornerRadius
        self.multipleSelect = multipleSelect
        self.delegate = target
        
//        var bounds = frame
//        bounds.origin.x = 0
//        bounds.origin.y = 0
//        self.scrollView.frame = bounds
//        self.addSubview(self.scrollView)
        self.setupWith(labelTextArray: labelTextArray)
    }
    
    func setupWith(labelTextArray: [String], target: DynamicLabelViewDelegate, arrangementType: ArrangementType = .center, labelFontSize: CGFloat = 12.0, labelHeight: CGFloat = 25.0, labelSpace: CGFloat = 8.0, selectTextColor: UIColor = .white, unSelectTextColor: UIColor = color_1A1C69, selectBgColor: UIColor = color_1A1C69, unSelectBgColor: UIColor = .white, borderWidth: CGFloat = 1, borderColor: UIColor = color_1A1C69, layerCornerRadius: CGFloat? = nil, multipleSelect: Bool = false) {
        self.arrangementType = arrangementType
        self.labelFontSize = labelFontSize
        self.labelHeight = labelHeight
        self.labelSpace = labelSpace
        self.selectTextColor = selectTextColor
        self.unSelectTextColor = unSelectTextColor
        self.selectBgColor = selectBgColor
        self.unSelectBgColor = unSelectBgColor
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.layerCornerRadius = layerCornerRadius
        self.multipleSelect = multipleSelect
        self.delegate = target
        
        self.setupWith(labelTextArray: labelTextArray)
    }
    
    /// Call this method from viewDidLayoutSubviews
    func resizeFrame(_ frame: CGRect) {
        self.frame = frame
        var a: [String] = []
        for label in self.labelArray {
            if let text = label.text {
                a.append(text)
            }
        }
        setupWith(labelTextArray: a)
    }
    
    /// Reflash the data
    func reflashViewWithLabelTextArray(_ labelTextArray: [String]) {
        self.setupWith(labelTextArray: labelTextArray)
    }
    
    func resetSelectStatus(_ selectedIndex: [Int]) {
        self.selectedIndex = selectedIndex
        self.labelArray = self.labelArray.map({ (label) -> TagLabel in
            label.isSelected = false
            return label
        })
        
        for index in selectedIndex {
            labelArray[index].isSelected = true
        }
    }
    
    private func setupWith(labelTextArray: [String]) {
        
        labelArray.removeAll()
        selectedIndex.removeAll()
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        
        let viewWidth = self.frame.size.width
        
        // 將所有要呈現的label加入array中
        for i in 0..<labelTextArray.count {
            let label = TagLabel(frame: CGRect(x: 0, y: 0, width: 30.0, height: labelHeight))
            label.text = labelTextArray[i]
            label.textColor = unSelectTextColor
            label.backgroundColor = unSelectBgColor
            label.font = UIFont.systemFont(ofSize: labelFontSize)
            label.textAlignment = .center
            label.tag = i
            label.layer.borderWidth = borderWidth
            label.layer.borderColor = borderColor.cgColor
            label.clipsToBounds = true
            label.selectBgColor = selectBgColor
            label.unSelectBgColor = unSelectBgColor
            label.selectTextColor = selectTextColor
            label.unSelectTextColor = unSelectTextColor
            
            label.sizeToFit()
            
            let g = UITapGestureRecognizer(target: self, action: #selector(selectLabel(_:)))
            g.numberOfTapsRequired = 1
            label.addGestureRecognizer(g)
            label.isUserInteractionEnabled = true
            
            var frame = label.frame
            frame.size.height = labelHeight
            if frame.size.width > viewWidth {
                frame.size.width = viewWidth
            }
            if frame.size.width < frame.size.height {
                frame.size.width = frame.size.height
            }
            frame.size.width += 8 // 讓字體與border分開一點
            label.layer.cornerRadius = (layerCornerRadius != nil) ? layerCornerRadius! : frame.size.height / 2
            label.frame = frame
            
            labelArray.append(label)
        }
        
        // 依序排放label
        setupContentWith(from: 0, to: labelArray.count, currentY: 15)
    }
    
    private func setupContentWith(from: Int, to: Int, currentY: CGFloat) {
        
        var lineWidth: CGFloat = 0
        
        // 先計算是否要換行
        for i in from..<to {
            let label = labelArray[i]
            if lineWidth + label.frame.size.width < self.frame.size.width {
                // 如果不需換行，則繼續加lineWidth，直至lineWidth大於self.frame.size.width，代表此行放不下了
                lineWidth += (label.frame.size.width + labelSpace)
                if i == labelArray.count - 1 { // 雖然不用換行，但如果是最後一個，就把最後一行的label加上去
                    lineWidth -= labelSpace
                    addLabel(from: from, to: labelArray.count, lineWidth: lineWidth, currentY: currentY)
                    return
                }
            } else {
                // 如果要換行，就把上一行的label加上去
                lineWidth -= labelSpace
                addLabel(from: from, to: i, lineWidth: lineWidth, currentY: currentY)
                return
            }
        }
    }
    
    private func addLabel(from: Int, to: Int, lineWidth: CGFloat, currentY: CGFloat) {
        var currentX: CGFloat = labelSpace
        
        if arrangementType == .center {
            currentX = (self.frame.size.width - lineWidth) / 2
            currentXArray.append(currentX)
            
            if to == labelArray.count {
                if let result = mostFrequent(array: currentXArray) {
                    currentX = result.value
                }
            }
        }
        
        for i in from..<to {
            let label = labelArray[i]
            var frame = label.frame
            frame.origin.x = currentX
            frame.origin.y = currentY
            label.frame = frame
            self.addSubview(label)
            
            currentX += (label.frame.size.width + labelSpace)
            labelArray[i].frame = frame
        }
        
        if to != labelArray.count {
            setupContentWith(from: to, to: labelArray.count, currentY: currentY + labelHeight + labelSpace)
        } else {
            var viewFrame = self.frame
            viewFrame.size.height = currentY + labelHeight + 15
            self.frame = viewFrame
        }
    }
    
    @objc private func selectLabel(_ sender: UITapGestureRecognizer) {
        if let touchLabel = sender.view as? TagLabel {
            if multipleSelect {
                if touchLabel.isSelected {
                    if let index = selectedIndex.index(of: touchLabel.tag) {
                        selectedIndex.remove(at: index)
                    }
                } else {
                    selectedIndex.append(touchLabel.tag)
                }
                selectedIndex.sort()
                labelArray[touchLabel.tag].isSelected = !labelArray[touchLabel.tag].isSelected
                self.delegate?.didSelectItemsIndex(selectedIndex)
            } else {
                labelArray = labelArray.map({ (label) -> TagLabel in
                    if label.tag == touchLabel.tag {
                        label.isSelected = !label.isSelected
                        if label.isSelected {
                            self.selectedIndex = [label.tag]
                        } else {
                            self.selectedIndex = []
                        }
                        self.delegate?.didSelectItemsIndex(self.selectedIndex)
                    } else {
                        label.isSelected = false
                    }
                    return label
                })
            }
        }
    }
    
    // 參考連結：https://stackoverflow.com/a/38416464/7103908
    // 找出array中出現最多次的物件
    private func mostFrequent<T: Hashable>(array: [T]) -> (value: T, count: Int)? {
        
        let counts = array.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        
        if let (value, count) = counts.max(by: { $0.1 < $1.1 }) {
            return (value, count)
        }
        
        return nil
    }
}
