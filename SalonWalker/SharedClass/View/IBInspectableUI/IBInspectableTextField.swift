//
//  LocalizedTextField.swift
//  SalonWalker
//
//  Created by skywind on 2018/3/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class IBInspectableTextField: UITextField, UITextFieldDelegate {

//    enum LocalizedTextFieldMode : Int {
//        case unspecific = 0
//        case general
//        case email
//        case password
//        case dropdown
//        case cellphone
//    }
    
//    weak var referenceTextField: UITextField?
    
    private var leftImageViewWidth: CGFloat {
        return self.bounds.size.height * 0.46
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            self.layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var placeHolderLocolizedKey: String? {
        didSet {
            updatePlaceholder()
        }
    }
    
    @IBInspectable var placeHoldercolor: UIColor = color_C7C7CD {
        didSet {
            updatePlaceholder()
        }
    }
    
    @IBInspectable var leftImageName: String? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var leftImagePadding: CGFloat = 0.0
    
    @IBInspectable var textPadding: CGFloat = 0.0
    
    private func updateView() {
        if let leftImageName = leftImageName {
            self.leftViewMode = .always
            let imageView = UIImageView(frame: CGRect(x: leftImagePadding, y: 0, width: leftImageViewWidth, height: leftImageViewWidth))
            imageView.image = UIImage(named: leftImageName)
            imageView.contentMode = .scaleAspectFit
            self.leftView = imageView
        } else {
            self.leftViewMode = .never
            self.leftView = nil
        }
    }
    
    private func updatePlaceholder() {
        if let placeHolderLocolizedKey = placeHolderLocolizedKey {
            self.attributedPlaceholder =
                NSAttributedString(string: LocalizedString(placeHolderLocolizedKey), attributes: [NSAttributedString.Key.foregroundColor: placeHoldercolor])
        }
    }
    
//    var type = LocalizedTextFieldMode.unspecific
//    var shouldChangeColor = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        setupUI()
//        addTarget(self, action: #selector(textFieldDidChange), for: .valueChanged)
//        shouldChangeColor = false
    }
    
//    func setupUI() {
//        attributedPlaceholder = NSAttributedString(string: LocalizedString(placeHolderLocolizedKey), attributes: [
//            .foregroundColor : UIColor.lightGray,
//            .font : UIFont.boldSystemFont(ofSize: 16)
//            ])
//        if cornerRadius > 0 {
//            layer.cornerRadius = cornerRadius
//            layer.masksToBounds = true
//        }
//        if borderWidth > 0 {
//            layer.borderWidth = borderWidth
//            layer.borderColor = borderColor?.cgColor
//        }
//        if delegate == nil {
//            delegate = self
//        }
//    }

    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var bounds = bounds
        bounds.origin.x += textPadding
        bounds.size.width -= textPadding
        if leftView != nil {
            bounds.origin.x += (leftImageViewWidth + leftImagePadding)
            bounds.size.width -= (leftImageViewWidth + leftImagePadding)
        }
        return bounds
    }
    
    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var bounds = bounds
        bounds.origin.x += textPadding
        bounds.size.width -= textPadding
        if leftView != nil {
            bounds.origin.x += (leftImageViewWidth + leftImagePadding)
            bounds.size.width -= (leftImageViewWidth + leftImagePadding)
        }
        return bounds
    }
    
    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftImagePadding
        return textRect
    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }

//    @objc func textFieldDidChange() {
//        if shouldChangeColor {
//            if checkData(withType: type) {
//                if borderColor != nil {
//                    layer.borderColor = borderColor?.cgColor
//                }
//                attributedPlaceholder = NSAttributedString(string: LocalizedString(placeHolderLocolizedKey), attributes: [
//                    .foregroundColor : UIColor.lightGray,
//                    .font : UIFont.boldSystemFont(ofSize: 16)
//                    ])
//                shouldChangeColor = false
//            }
//            else {
//                let orangeColor: UIColor = .orange
//                layer.borderColor = orangeColor.cgColor
//                attributedPlaceholder = NSAttributedString(string: LocalizedString(placeHolderLocolizedKey), attributes: [
//                    .foregroundColor : orangeColor,
//                    .font : UIFont.boldSystemFont(ofSize: 16)
//                    ])
//            }
//            setNeedsDisplay()
//        }
//    }
    
    // MARK: - Methods
//    func checkData(withType type: LocalizedTextFieldMode) -> Bool {
//        self.type = type
//        var checkResult = false
//        switch type {
//        case .unspecific:
//            checkResult = true
//            break
//        case .general:
//            checkResult = RegEx.validateGeneral(text)
//            checkResult = true
//            break
//        case .email:
//            checkResult = true
//            break
//        }
//        return checkResult
//    }
    
//    func checkDataAndChangeColor(withType type: LocalizedTextFieldMode) -> Bool {
//        shouldChangeColor = true
//        textFieldDidChange()
//        return checkData(withType: type)
//    }
}
