//
//  LocalizedButton.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/14.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class IBInspectableButton: UIButton {
    
    private var shadowView: UIView?
    
    /*
     top: image在上，label在下
     left: image在左，label在右
     bottom: image在下，label在上
     right: image在右，label在左
     **/
    private enum ButtonEdgeInsetStyle {
        case top, left, bottom, right, none
    }
    
    private enum ButtonImageViewContentMode {
        case scaleToFill, scaleAspectFill, scaleAspectFit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayer()
    }
    
    @IBInspectable var titleLocalizedKey: String? {
        didSet {
            if let titleLocalizedKey = titleLocalizedKey {
                setTitle(LocalizedString(titleLocalizedKey), for: .normal)
                setTitle(LocalizedString(titleLocalizedKey), for: .selected)
            }
        }
    }
    
    // 圓角
    @IBInspectable var cornerRadius: CGFloat = 0
    @IBInspectable var cornersText: String = "topLeft,topRight,bottomLeft,bottomRight"
    
    // 邊框
    @IBInspectable var borderWidth: CGFloat = 0
    @IBInspectable var borderColor: UIColor = .white
    
    // 陰影
    @IBInspectable var shadowColor: UIColor = .clear
    @IBInspectable var shadowRadius: CGFloat = 0
    @IBInspectable var shadowOpacity: Float = 0
    @IBInspectable var shadowOffset: CGSize = CGSize.zero
    
    @IBInspectable var buttonEdgeInsetStyleString: String = "none" {
        didSet {
            switch buttonEdgeInsetStyleString {
            case "top":
                buttonEdgeInsetStyle = .top
                break
            case "left":
                buttonEdgeInsetStyle = .left
                break
            case "bottom":
                buttonEdgeInsetStyle = .bottom
                break
            case "right":
                buttonEdgeInsetStyle = .right
                break
            case "none":
                buttonEdgeInsetStyle = .none
                break
            default:
                buttonEdgeInsetStyle = .none
                break
            }
        }
    }
    
    @IBInspectable var buttonImageViewContentModeString: String = "scaleAspectFit" {
        didSet {
            switch buttonImageViewContentModeString {
            case "scaleToFill":
                buttonImageViewContentMode = .scaleToFill
                break
            case "scaleAspectFill":
                buttonImageViewContentMode = .scaleAspectFill
                break
            case "scaleAspectFit":
                buttonImageViewContentMode = .scaleAspectFit
                break
            default:
                buttonImageViewContentMode = .scaleToFill
                break
            }
        }
    }
    
    @IBInspectable var imageViewLabelSpace: CGFloat = 0 {
        didSet {
            updateEdgeInsets()
        }
    }
    
    private var imageWith: CGFloat {
        return self.imageView?.frame.size.width ?? 0
    }
    
    private var imageHeight: CGFloat {
        return self.imageView?.frame.size.height ?? 0
    }
    
    private var labelWidth: CGFloat {
        return self.titleLabel?.intrinsicContentSize.width ?? 0
    }
    
    private var labelHeight: CGFloat {
        return self.titleLabel?.intrinsicContentSize.height ?? 0
    }
    
    private var buttonEdgeInsetStyle: ButtonEdgeInsetStyle = .none {
        didSet {
            updateEdgeInsets()
        }
    }
    
    private var buttonImageViewContentMode: ButtonImageViewContentMode = .scaleToFill {
        didSet {
            switch buttonImageViewContentMode {
            case .scaleToFill:
                self.imageView?.contentMode = .scaleToFill
                break
            case .scaleAspectFill:
                self.imageView?.contentMode = .scaleAspectFill
                break
            case .scaleAspectFit:
                self.imageView?.contentMode = .scaleAspectFit
                break
            }
        }
    }
    
    private func updateEdgeInsets() {
        var imageEdgeInsets = UIEdgeInsets.zero
        var labelEdgeInsets = UIEdgeInsets.zero
        
        switch buttonEdgeInsetStyle {
        case .top:
            imageEdgeInsets = UIEdgeInsets.init(top: -labelHeight - imageViewLabelSpace/2.0, left: 0, bottom: 0, right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets.init(top: 0, left: -imageWith, bottom: -imageHeight-imageViewLabelSpace/2.0, right: 0)
            break
        case .left:
            imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -imageViewLabelSpace/2.0, bottom: 0, right: imageViewLabelSpace/2.0)
            labelEdgeInsets = UIEdgeInsets.init(top: 0, left: imageViewLabelSpace/2.0, bottom: 0, right: -imageViewLabelSpace/2.0)
            break
        case .bottom:
            imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: -labelHeight-imageViewLabelSpace/2.0, right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets.init(top: -imageHeight-imageViewLabelSpace/2.0, left: -imageWith, bottom: 0, right: 0)
            break
        case .right:
            imageEdgeInsets = UIEdgeInsets.init(top: 0, left: labelWidth+imageViewLabelSpace/2.0, bottom: 0, right: -labelWidth-imageViewLabelSpace/2.0)
            labelEdgeInsets = UIEdgeInsets.init(top: 0, left: -imageWith-imageViewLabelSpace/2.0, bottom: 0, right: imageWith+imageViewLabelSpace/2.0)
            break
        case .none:
            labelEdgeInsets = UIEdgeInsets.init(top: 0, left: imageViewLabelSpace, bottom: 0, right: 0)
            break
        }
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
    }
    
    private func updateLayer() {
        let array = cornersText.components(separatedBy: ",")
        
        if #available(iOS 11.0, *) {
            var maskedCorners: CACornerMask = []
            for text in array {
                if text == "topLeft" {
                    maskedCorners = [maskedCorners,.layerMinXMinYCorner]
                }
                if text == "topRight" {
                    maskedCorners = [maskedCorners,.layerMaxXMinYCorner]
                }
                if text == "bottomLeft" {
                    maskedCorners = [maskedCorners,.layerMinXMaxYCorner]
                }
                if text == "bottomRight" {
                    maskedCorners = [maskedCorners,.layerMaxXMaxYCorner]
                }
            }
            self.layer.maskedCorners = maskedCorners
            
            self.layer.cornerRadius = cornerRadius
            
            self.layer.borderWidth = borderWidth
            self.layer.borderColor = borderColor.cgColor
            
            self.layer.shadowColor = shadowColor.cgColor
            self.layer.shadowRadius = shadowRadius
            self.layer.shadowOffset = shadowOffset
            self.layer.shadowOpacity = shadowOpacity
            self.layer.backgroundColor = self.backgroundColor?.cgColor
            self.layer.masksToBounds = false
            self.clipsToBounds = false
            self.imageView?.layer.cornerRadius = cornerRadius
            
        } else {
            
            // 繪製路徑
            let tl = array.filter{$0 == "topLeft"}.count > 0
            let tr = array.filter{$0 == "topRight"}.count > 0
            let bl = array.filter{$0 == "bottomLeft"}.count > 0
            let br = array.filter{$0 == "bottomRight"}.count > 0
            
            var corners: UIRectCorner = []
            if (tl) { corners = [corners, .topLeft] }
            if (tr) { corners = [corners, .topRight] }
            if (bl) { corners = [corners, .bottomLeft] }
            if (br) { corners = [corners, .bottomRight] }
            
            // 如果需要圓角，則按照需求(左上、右上、左下、右下)繪製路徑；如果沒有設置圓角，則路徑為自身的bounds
            let cornerPath = (cornerRadius > 0) ? UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)) : UIBezierPath(rect: self.bounds)
            
            // 圓角
            if cornerRadius != 0 {
                let cornerMask = CAShapeLayer()
                cornerMask.frame = bounds
                cornerMask.path = cornerPath.cgPath
                self.layer.mask = cornerMask
            }
            
            // 邊框
            if borderWidth != 0 {
                let border = CAShapeLayer()
                border.frame = self.bounds
                border.path = cornerPath.cgPath
                border.strokeColor = borderColor.cgColor
                border.fillColor = UIColor.clear.cgColor
                border.lineWidth = borderWidth
                self.layer.addSublayer(border)
            }
            
            // 陰影
            if shadowColor != .clear, shadowView == nil {
                shadowView = UIView(frame: self.frame)
                shadowView?.backgroundColor = UIColor.clear
                shadowView?.layer.masksToBounds = false
                shadowView?.layer.shadowPath = cornerPath.cgPath
                shadowView?.layer.shadowColor = shadowColor.cgColor
                shadowView?.layer.shadowOpacity = shadowOpacity
                shadowView?.layer.shadowOffset = shadowOffset
                shadowView?.layer.shadowRadius = shadowRadius
                self.superview?.insertSubview(shadowView!, belowSubview: self)
            }
        }
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        updateEdgeInsets()
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        updateEdgeInsets()
    }
}
