//
//  SVGLayer.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/8.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import SwiftSVG

// SVG參考網址：http://www.oxxostudio.tw/articles/201406/svg-04-path-1.html

enum HairStyle: Int {
    case Bangs = 1
    case SideParting
    case CenterParting
    case Bob
}

enum Gender {
    case Male
    case Female
}

class SVGLayer: NSObject {
    
    static func getSVGLayersWith(sideLength: CGFloat, sliderPercentage: CGFloat, hairStyle: HairStyle, gender: Gender, color: UIColor) -> [CAShapeLayer] {
        
        if gender == .Male {
            switch hairStyle {
            case .Bangs: return svgHairLayer_Male_Bangs(sideLength: sideLength, sliderPercentage: sliderPercentage, color: color)
            case .SideParting: return svgHairLayer_Male_SideParting(sideLength: sideLength, sliderPercentage: sliderPercentage, color: color)
            case .CenterParting: return svgHairLayer_Male_CenterParting(sideLength: sideLength, sliderPercentage: sliderPercentage, color: color)
            case .Bob: return svgHairLayer_Male_Bob(sideLength: sideLength, sliderPercentage: sliderPercentage, color: color)
            }
        } else {
            switch hairStyle {
            case .Bangs: return svgHairLayer_Female_Bangs(sideLength: sideLength, sliderPercentage: sliderPercentage, color: color)
            case .SideParting: return svgHairLayer_Female_SideParting(sideLength: sideLength, sliderPercentage: sliderPercentage, color: color)
            case .CenterParting: return svgHairLayer_Female_CenterParting(sideLength: sideLength, sliderPercentage: sliderPercentage, color: color)
            case .Bob: return svgHairLayer_Female_Bob(sideLength: sideLength, sliderPercentage: sliderPercentage, color: color)
            }
        }
    }
    
    /// 鮑伯男
    static private func svgHairLayer_Male_Bob(sideLength: CGFloat, sliderPercentage: CGFloat, color: UIColor) -> [CAShapeLayer] {
        let scale: CGFloat = sideLength / 100
        
        //臉的弧形
        let face = "M\(14 * scale),\(45 * scale) L\(14 * scale),\(55 * scale) C\(14 * scale),\(70 * scale) \(17 * scale),\(92 * scale) \(51 * scale),\(95 * scale) C\(82 * scale),\(92 * scale) \(85 * scale),\(70 * scale) \(85 * scale),\(55 * scale) L\(85 * scale),\(45 * scale)"
        let facePath = UIBezierPath(pathString: face)
        let faceLayer = CAShapeLayer()
        faceLayer.lineWidth = 1.5
        faceLayer.strokeColor = color.cgColor
        faceLayer.fillColor = UIColor.white.cgColor
        faceLayer.path = facePath.cgPath
        
        //平平的瀏海
        let line1 = "M\(10 * scale),\(45 * scale) L\(90 * scale),\(45 * scale)"
        let line1Path = UIBezierPath(pathString: line1)
        let line1Layer = CAShapeLayer()
        line1Layer.lineWidth = 1.5
        line1Layer.strokeColor = color.cgColor
        line1Layer.fillColor = UIColor.clear.cgColor
        line1Layer.path = line1Path.cgPath
        
        //左邊的造型線
        let line2 = "M\(30 * scale),\(29 * scale) Q\(32 * scale),\(35 * scale) \(26 * scale),\(45 * scale)"
        let line2Path = UIBezierPath(pathString: line2)
        let line2Layer = CAShapeLayer()
        line2Layer.lineWidth = 1.5
        line2Layer.strokeColor = color.cgColor
        line2Layer.fillColor = UIColor.clear.cgColor
        line2Layer.path = line2Path.cgPath
        
        //中間的造型線
        let line3 = "M\(40 * scale),\(32 * scale) Q\(39 * scale),\(40 * scale) \(36 * scale),\(45 * scale)"
        let line3Path = UIBezierPath(pathString: line3)
        let line3Layer = CAShapeLayer()
        line3Layer.lineWidth = 1.5
        line3Layer.strokeColor = color.cgColor
        line3Layer.fillColor = UIColor.clear.cgColor
        line3Layer.path = line3Path.cgPath
        
        //右邊的造型線
        let line4 = "M\(49 * scale),\(32 * scale) Q\(48 * scale),\(40 * scale) \(45 * scale),\(45 * scale)"
        let line4Path = UIBezierPath(pathString: line4)
        let line4Layer = CAShapeLayer()
        line4Layer.lineWidth = 1.5
        line4Layer.strokeColor = color.cgColor
        line4Layer.fillColor = UIColor.clear.cgColor
        line4Layer.path = line4Path.cgPath
        
        let valueRC1x = sliderPercentage * 1.2 * -1 * scale
        let valueRC1y = sliderPercentage * 2.4 * scale
        let valueRC2y = sliderPercentage * 24  * scale
        let valueRC3x = sliderPercentage * 9.6 * -1 * scale
        let valueRC3y = sliderPercentage * 30 * scale
        let valueLC1y = sliderPercentage * 6 * scale
        let valueLC2y = sliderPercentage * 24 * scale
        let valueLC3x = sliderPercentage * 9.6 * scale
        let valueLC3y = sliderPercentage * 30 * scale
        
        //頭髮
        let hair = "M\(sideLength / 2),0 C\(73 * scale),0 \(97 * scale),\(6 * scale) \(99 * scale),\(45 * scale) C\(99 * scale + valueRC1x),\(50 * scale + valueRC1y) \(102 * scale),\(48 * scale + valueRC2y) \(86 * scale + valueRC3x),\(50 * scale + valueRC3y) M\(sideLength / 2),0 C\(27 * scale),0 \(3 * scale),\(6 * scale) \(1 * scale),\(45 * scale) C\(2 * scale),\(50 * scale + valueLC1y) \(-2 * scale),\(48 * scale + valueLC2y) \(14 * scale + valueLC3x),\(50 * scale + valueLC3y)"
        
        let hairPath = UIBezierPath(pathString: hair)
        let hairLayer = CAShapeLayer()
        hairLayer.lineWidth = 1.5
        hairLayer.strokeColor = color.cgColor
        hairLayer.fillColor = UIColor.clear.cgColor
        hairLayer.path = hairPath.cgPath
        
        return [hairLayer, faceLayer, line1Layer, line2Layer, line3Layer, line4Layer]
    }
    
    
    /// 鮑伯女
    static private func svgHairLayer_Female_Bob(sideLength: CGFloat, sliderPercentage: CGFloat, color: UIColor) -> [CAShapeLayer] {
        let scale: CGFloat = sideLength / 100
        let value = sliderPercentage * 50 * scale
        
        //臉的弧形
        let face = "M\(16 * scale),\(45 * scale) L\(16 * scale),\(55 * scale) C\(16 * scale),\(70 * scale) \(19 * scale),\(92 * scale) \(51 * scale),\(96 * scale) C\(80 * scale),\(92 * scale) \(83 * scale),\(70 * scale) \(83 * scale),\(55 * scale) L\(83 * scale),\(45 * scale)"
        let facePath = UIBezierPath(pathString: face)
        let faceLayer = CAShapeLayer()
        faceLayer.lineWidth = 1.5
        faceLayer.strokeColor = color.cgColor
        faceLayer.fillColor = UIColor.white.cgColor
        faceLayer.path = facePath.cgPath
        
        //頭髮
        let hair = "M\(sideLength / 2),\(3 * scale) C\(72 * scale),\(5 * scale) \(87 * scale),\(15 * scale) \(88 * scale),\(47 * scale) M\(sideLength / 2),\(3 * scale) C\(28 * scale),\(5 * scale) \(12 * scale),\(15 * scale) \(12 * scale),\(47 * scale)"
        
        let hairPath = UIBezierPath(pathString: hair)
        let hairLayer = CAShapeLayer()
        hairLayer.lineWidth = 1.5
        hairLayer.strokeColor = color.cgColor
        hairLayer.fillColor = UIColor.clear.cgColor
        hairLayer.path = hairPath.cgPath
        
        //頭髮下緣的造型線
        let line1 = "M\(88 * scale),\(47 * scale) L\(88 * scale),\(53 * scale + value) L\(90 * scale),\(57 * scale + value) C\(80 * scale),\(55 * scale + value) \(82 * scale),\(41 * scale + value) \(80 * scale),\(57 * scale + value) C\(76 * scale),\(65 * scale + value) \(74 * scale),\(41 * scale + value) \(70 * scale),\(57 * scale + value) C\(66 * scale),\(65 * scale + value) \(64 * scale),\(41 * scale + value) \(60 * scale),\(57 * scale + value) C\(56 * scale),\(65 * scale + value) \(54 * scale),\(41 * scale + value) \(50 * scale),\(57 * scale + value) C\(46 * scale),\(65 * scale + value) \(44 * scale),\(41 * scale + value) \(40 * scale),\(57 * scale + value) C\(36 * scale),\(65 * scale + value) \(34 * scale),\(41 * scale + value) \(30 * scale),\(57 * scale + value) C\(26 * scale),\(65 * scale + value) \(24 * scale),\(41 * scale + value) \(20 * scale),\(57 * scale + value) C\(14 * scale),\(65 * scale + value) \(22 * scale),\(39 * scale + value) \(10 * scale),\(57 * scale + value) L\(12 * scale),\(45 * scale + value) L\(12 * scale),\(47 * scale)"
        let line1Path = UIBezierPath(pathString: line1)
        let line1Layer = CAShapeLayer()
        line1Layer.lineWidth = 1.5
        line1Layer.strokeColor = color.cgColor
        line1Layer.fillColor = UIColor.clear.cgColor
        line1Layer.path = line1Path.cgPath
        
        //瀏海的造型線
        let line2 = "M\(16 * scale),\(47 * scale) C\(25 * scale),\(38 * scale) \(75 * scale),\(38 * scale) \(83 * scale),\(47 * scale)"
        let line2Path = UIBezierPath(pathString: line2)
        let line2Layer = CAShapeLayer()
        line2Layer.lineWidth = 1.5
        line2Layer.strokeColor = color.cgColor
        line2Layer.fillColor = UIColor.clear.cgColor
        line2Layer.path = line2Path.cgPath
        
        //左邊的造型線
        let line3 = "M\(35 * scale),\(23 * scale) C\(32 * scale),\(21 * scale) \(26 * scale),\(39 * scale) \(29 * scale),\(41 * scale)"
        let line3Path = UIBezierPath(pathString: line3)
        let line3Layer = CAShapeLayer()
        line3Layer.lineWidth = 1.5
        line3Layer.strokeColor = color.cgColor
        line3Layer.fillColor = UIColor.clear.cgColor
        line3Layer.path = line3Path.cgPath
        
        //中間的造型線
        let line4 = "M\(41 * scale),\(28 * scale) C\(40 * scale),\(27 * scale) \(38 * scale),\(37 * scale) \(39 * scale),\(39 * scale)"
        let line4Path = UIBezierPath(pathString: line4)
        let line4Layer = CAShapeLayer()
        line4Layer.lineWidth = 1.5
        line4Layer.strokeColor = color.cgColor
        line4Layer.fillColor = UIColor.clear.cgColor
        line4Layer.path = line4Path.cgPath
        
        //右側的造型線
        let line5 = "M\(70 * scale),\(23 * scale) C\(72 * scale),\(25 * scale) \(76 * scale),\(37 * scale) \(74 * scale),\(42 * scale)"
        let line5Path = UIBezierPath(pathString: line5)
        let line5Layer = CAShapeLayer()
        line5Layer.lineWidth = 1.5
        line5Layer.strokeColor = color.cgColor
        line5Layer.fillColor = UIColor.clear.cgColor
        line5Layer.path = line5Path.cgPath
        
        return [line1Layer, faceLayer, hairLayer, line2Layer, line3Layer, line4Layer, line5Layer]
    }
    
    /// 瀏海男
    static private func svgHairLayer_Male_Bangs(sideLength: CGFloat, sliderPercentage: CGFloat, color: UIColor) -> [CAShapeLayer] {
        let scale: CGFloat = sideLength / 100
        let value = sliderPercentage * 8.4 * scale
        
        //臉的弧形
        let face = "M\(14 * scale),\(20 * scale) L\(15 * scale),\(20 * scale) L\(14 * scale),\(30 * scale) C\(14 * scale),\(31 * scale) \(14 * scale),\(32 * scale) \(14 * scale),\(33 * scale) L\(14 * scale),\(55 * scale) C\(14 * scale),\(70 * scale) \(17 * scale),\(92 * scale) \(51 * scale),\(95 * scale) C\(82 * scale),\(92 * scale) \(85 * scale),\(70 * scale) \(85 * scale),\(55 * scale) L\(85 * scale),\(33 * scale) C\(85 * scale),\(25 * scale) \(83 * scale),\(18 * scale) \(78 * scale),\(13 * scale)"
        let facePath = UIBezierPath(pathString: face)
        let faceLayer = CAShapeLayer()
        faceLayer.lineWidth = 1.5
        faceLayer.strokeColor = color.cgColor
        faceLayer.fillColor = UIColor.clear.cgColor
        faceLayer.path = facePath.cgPath
        
        //左邊的造型線
        let line1 = "M\(33 * scale),\(22 * scale + value) Q\(28 * scale),\(28 * scale + value) \(25 * scale),\(38 * scale + value)"
        let line1Path = UIBezierPath(pathString: line1)
        let line1Layer = CAShapeLayer()
        line1Layer.lineWidth = 1.5
        line1Layer.strokeColor = color.cgColor
        line1Layer.fillColor = UIColor.clear.cgColor
        line1Layer.path = line1Path.cgPath
        
        //中間的造型線
        let line2 = "M\(40 * scale),\(29 * scale + value) Q\(39 * scale),\(31 * scale + value) \(36 * scale),\(38 * scale + value)"
        let line2Path = UIBezierPath(pathString: line2)
        let line2Layer = CAShapeLayer()
        line2Layer.lineWidth = 1.5
        line2Layer.strokeColor = color.cgColor
        line2Layer.fillColor = UIColor.clear.cgColor
        line2Layer.path = line2Path.cgPath
        
        //右邊的造型線
        let line3 = "M\(49 * scale),\(29 * scale + value) Q\(48 * scale),\(31 * scale + value) \(45 * scale),\(38 * scale + value)"
        let line3Path = UIBezierPath(pathString: line3)
        let line3Layer = CAShapeLayer()
        line3Layer.lineWidth = 1.5
        line3Layer.strokeColor = color.cgColor
        line3Layer.fillColor = UIColor.clear.cgColor
        line3Layer.path = line3Path.cgPath
        
        //頭髮
        let hair = "M\(8 * scale),\(38 * scale) L\(8 * scale),\(38 * scale + value) C\(6 * scale),\(10 * scale) \(sideLength / 3 * 1),\(0 * scale) \(sideLength / 2),\(0 * scale) C\(sideLength / 3 * 2),\(0 * scale) \(92 * scale),\(10 * scale + value / 4) \(90 * scale),\(38 * scale + value) L\(88 * scale),\(38 * scale + value) L\(74 * scale),\(38 * scale + value) L\(71 * scale),\(30 * scale + value) L\(68 * scale),\(38 * scale + value) L\(8 * scale),\(38 * scale + value) L\(8 * scale),\(38 * scale + value)"
        
        let hairPath = UIBezierPath(pathString: hair)
        let hairLayer = CAShapeLayer()
        hairLayer.lineWidth = 1.5
        hairLayer.strokeColor = color.cgColor
        hairLayer.fillColor = UIColor.white.cgColor
        hairLayer.path = hairPath.cgPath
        
        return [faceLayer, hairLayer, line1Layer, line2Layer, line3Layer]
    }
    
    /// 瀏海女
    static private func svgHairLayer_Female_Bangs(sideLength: CGFloat, sliderPercentage: CGFloat, color: UIColor) -> [CAShapeLayer] {
        let scale: CGFloat = sideLength / 100
        let value = sliderPercentage * 50 * scale
        
        //臉的弧形
        let face = "M\(16 * scale),\(45 * scale) L\(16 * scale),\(55 * scale) C\(16 * scale),\(70 * scale) \(19 * scale),\(92 * scale) \(51 * scale),\(96 * scale) C\(80 * scale),\(92 * scale) \(83 * scale),\(70 * scale) \(83 * scale),\(55 * scale) L\(83 * scale),\(45 * scale)"
        let facePath = UIBezierPath(pathString: face)
        let faceLayer = CAShapeLayer()
        faceLayer.lineWidth = 1.5
        faceLayer.strokeColor = color.cgColor
        faceLayer.fillColor = UIColor.white.cgColor
        faceLayer.path = facePath.cgPath
        
        //頭髮上緣
        let hair = "M\(sideLength / 2),\(3 * scale) C\(72 * scale),\(5 * scale) \(87 * scale),\(15 * scale) \(88 * scale),\(47 * scale) M\(sideLength / 2),\(3 * scale) C\(28 * scale),\(5 * scale) \(12 * scale),\(15 * scale) \(12 * scale),\(47 * scale)"
        
        let hairPath = UIBezierPath(pathString: hair)
        let hairLayer = CAShapeLayer()
        hairLayer.lineWidth = 1.5
        hairLayer.strokeColor = color.cgColor
        hairLayer.fillColor = UIColor.clear.cgColor
        hairLayer.path = hairPath.cgPath
        
        //頭髮下緣的造型線
        let line1 = "M\(88 * scale),\(47 * scale) L\(88 * scale),\(53 * scale + value) L\(90 * scale),\(57 * scale + value) C\(80 * scale),\(55 * scale + value) \(82 * scale),\(41 * scale + value) \(80 * scale),\(57 * scale + value) C\(76 * scale),\(65 * scale + value) \(74 * scale),\(41 * scale + value) \(70 * scale),\(57 * scale + value) C\(66 * scale),\(65 * scale + value) \(64 * scale),\(41 * scale + value) \(60 * scale),\(57 * scale + value) C\(56 * scale),\(65 * scale + value) \(54 * scale),\(41 * scale + value) \(50 * scale),\(57 * scale + value) C\(46 * scale),\(65 * scale + value) \(44 * scale),\(41 * scale + value) \(40 * scale),\(57 * scale + value) C\(36 * scale),\(65 * scale + value) \(34 * scale),\(41 * scale + value) \(30 * scale),\(57 * scale + value) C\(26 * scale),\(65 * scale + value) \(24 * scale),\(41 * scale + value) \(20 * scale),\(57 * scale + value) C\(14 * scale),\(65 * scale + value) \(22 * scale),\(39 * scale + value) \(10 * scale),\(57 * scale + value) L\(12 * scale),\(45 * scale + value) L\(12 * scale),\(47 * scale)"
        let line1Path = UIBezierPath(pathString: line1)
        let line1Layer = CAShapeLayer()
        line1Layer.lineWidth = 1.5
        line1Layer.strokeColor = color.cgColor
        line1Layer.fillColor = UIColor.clear.cgColor
        line1Layer.path = line1Path.cgPath
        
        //瀏海的造型線
        let line2 = "M\(16 * scale),\(45 * scale) C\(22 * scale),\(42 * scale) \(23 * scale),\(42 * scale) \(26 * scale),\(40 * scale) C\(26 * scale),\(38 * scale) \(27 * scale),\(31 * scale) \(29 * scale),\(26 * scale) C\(31 * scale),\(29 * scale) \(32 * scale),\(35 * scale) \(32 * scale),\(41 * scale) C\(31 * scale),\(40 * scale) \(32 * scale),\(40 * scale) \(34 * scale),\(40 * scale) C\(37 * scale),\(35 * scale) \(38 * scale),\(30 * scale) \(38 * scale),\(24 * scale) C\(41 * scale),\(29 * scale) \(42 * scale),\(36 * scale) \(41 * scale),\(40 * scale) C\(43 * scale),\(40 * scale) \(44 * scale),\(40 * scale) \(44 * scale),\(40 * scale) C\(47 * scale),\(38 * scale) \(45 * scale),\(38 * scale) \(48 * scale),\(23 * scale) C\(51 * scale),\(27 * scale) \(52 * scale),\(30 * scale) \(51 * scale),\(39 * scale) C\(53 * scale),\(39 * scale) \(46 * scale),\(39 * scale) \(60 * scale),\(41 * scale) C\(63 * scale),\(36 * scale) \(64 * scale),\(33 * scale) \(64 * scale),\(31 * scale) C\(66 * scale),\(33 * scale) \(66 * scale),\(37 * scale) \(66 * scale),\(41 * scale) C\(67 * scale),\(41 * scale) \(69 * scale),\(42 * scale) \(72 * scale),\(42 * scale) C\(72 * scale),\(40 * scale) \(75 * scale),\(35 * scale) \(74 * scale),\(31 * scale) C\(77 * scale),\(33 * scale) \(78 * scale),\(39 * scale) \(77 * scale),\(42 * scale) C\(82 * scale),\(44 * scale) \(83 * scale),\(43 * scale) \(83 * scale),\(45 * scale)"
        let line2Path = UIBezierPath(pathString: line2)
        let line2Layer = CAShapeLayer()
        line2Layer.lineWidth = 1.5
        line2Layer.strokeColor = color.cgColor
        line2Layer.fillColor = UIColor.white.cgColor
        line2Layer.path = line2Path.cgPath
        
        return [line1Layer, faceLayer, hairLayer, line2Layer]
    }
    
    /// 側分男
    static private func svgHairLayer_Male_SideParting(sideLength: CGFloat, sliderPercentage: CGFloat, color: UIColor) -> [CAShapeLayer] {
        let scale: CGFloat = sideLength / 100
        let value = sliderPercentage * 18 * scale
        
        //臉的弧形
        let face = "M\(26 * scale),\(36 * scale) L\(26 * scale),\(48 * scale) C\(26 * scale),\(83 * scale) \(45 * scale),\(93 * scale) \(63 * scale),\(94 * scale) C\(81 * scale),\(93 * scale) \(100 * scale),\(83 * scale) \(100 * scale),\(48 * scale) L\(100 * scale),\(40 * scale) C\(100 * scale),\(32 * scale) \(96 * scale),\(25 * scale) \(90 * scale),\(20 * scale)"
        let facePath = UIBezierPath(pathString: face)
        let faceLayer = CAShapeLayer()
        faceLayer.lineWidth = 1.5
        faceLayer.strokeColor = color.cgColor
        faceLayer.fillColor = UIColor.clear.cgColor
        faceLayer.path = facePath.cgPath
        
        //左邊的造型線
        let line1 = "M\(24 * scale - value),\(36 * scale) C\(30 * scale - value / 2),\(26 * scale + value / 2) \(44 * scale),\(4 * scale - value / 4) \(70 * scale),\(10 * scale) C\(72 * scale),\(8 * scale) \(88 * scale),\(16 * scale) \(90 * scale),\(18 * scale) C\(70 * scale),\(30 * scale) \(25 * scale),\(37 * scale) \(24 * scale - value),\(36 * scale)"
        let line1Path = UIBezierPath(pathString: line1)
        let line1Layer = CAShapeLayer()
        line1Layer.lineWidth = 1.5
        line1Layer.strokeColor = color.cgColor
        line1Layer.fillColor = UIColor.clear.cgColor
        line1Layer.path = line1Path.cgPath
        
        //右邊的造型線
        let line2 = "M\(75 * scale),\(25 * scale) C\(84 * scale),\(30 * scale) \(93 * scale),\(36 * scale) \(100 * scale),\(50 * scale)"
        let line2Path = UIBezierPath(pathString: line2)
        let line2Layer = CAShapeLayer()
        line2Layer.lineWidth = 1.5
        line2Layer.strokeColor = color.cgColor
        line2Layer.fillColor = UIColor.clear.cgColor
        line2Layer.path = line2Path.cgPath
        
        return [faceLayer, line1Layer, line2Layer]
    }
    
    /// 側分女
    static private func svgHairLayer_Female_SideParting(sideLength: CGFloat, sliderPercentage: CGFloat, color: UIColor) -> [CAShapeLayer] {
        let scale: CGFloat = sideLength / 100
        let value = sliderPercentage * 50 * scale
        
        //臉的弧形
        let face = "M\(16 * scale),\(45 * scale) L\(16 * scale),\(55 * scale) C\(16 * scale),\(70 * scale) \(19 * scale),\(92 * scale) \(51 * scale),\(96 * scale) C\(80 * scale),\(92 * scale) \(83 * scale),\(70 * scale) \(83 * scale),\(55 * scale) L\(83 * scale),\(45 * scale)"
        let facePath = UIBezierPath(pathString: face)
        let faceLayer = CAShapeLayer()
        faceLayer.lineWidth = 1.5
        faceLayer.strokeColor = color.cgColor
        faceLayer.fillColor = UIColor.white.cgColor
        faceLayer.path = facePath.cgPath
        
        //頭髮
        let hair1 = "M\(sideLength / 2),\(3 * scale) C\(72 * scale),\(5 * scale) \(87 * scale),\(15 * scale) \(88 * scale),\(47 * scale) M\(sideLength / 2),\(3 * scale) C\(28 * scale),\(5 * scale) \(12 * scale),\(15 * scale) \(12 * scale),\(47 * scale)"

        let hair1Path = UIBezierPath(pathString: hair1)
        let hair1Layer = CAShapeLayer()
        hair1Layer.lineWidth = 1.5
        hair1Layer.strokeColor = color.cgColor
        hair1Layer.fillColor = UIColor.clear.cgColor
        hair1Layer.path = hair1Path.cgPath
        
        //頭髮下緣的造型線
        let hair2 = "M\(88 * scale),\(47 * scale) L\(88 * scale),\(53 * scale + value) L\(90 * scale),\(57 * scale + value) C\(80 * scale),\(55 * scale + value) \(82 * scale),\(41 * scale + value) \(80 * scale),\(57 * scale + value) C\(76 * scale),\(65 * scale + value) \(74 * scale),\(41 * scale + value) \(70 * scale),\(57 * scale + value) C\(66 * scale),\(65 * scale + value) \(64 * scale),\(41 * scale + value) \(60 * scale),\(57 * scale + value) C\(56 * scale),\(65 * scale + value) \(54 * scale),\(41 * scale + value) \(50 * scale),\(57 * scale + value) C\(46 * scale),\(65 * scale + value) \(44 * scale),\(41 * scale + value) \(40 * scale),\(57 * scale + value) C\(36 * scale),\(65 * scale + value) \(34 * scale),\(41 * scale + value) \(30 * scale),\(57 * scale + value) C\(26 * scale),\(65 * scale + value) \(24 * scale),\(41 * scale + value) \(20 * scale),\(57 * scale + value) C\(14 * scale),\(65 * scale + value) \(22 * scale),\(39 * scale + value) \(10 * scale),\(57 * scale + value) L\(12 * scale),\(45 * scale + value) L\(12 * scale),\(47 * scale)"
        let hair2Path = UIBezierPath(pathString: hair2)
        let hair2Layer = CAShapeLayer()
        hair2Layer.lineWidth = 1.5
        hair2Layer.strokeColor = color.cgColor
        hair2Layer.fillColor = UIColor.clear.cgColor
        hair2Layer.path = hair2Path.cgPath
        
        //旁分的造型線
        let line1 = "M\(16 * scale),\(50 * scale) C\(25 * scale),\(50 * scale) \(38 * scale),\(39 * scale) \(40 * scale),\(32 * scale) C\(46 * scale),\(45 * scale) \(68 * scale),\(50 * scale) \(87 * scale),\(51 * scale)"
        let line1Path = UIBezierPath(pathString: line1)
        let line1Layer = CAShapeLayer()
        line1Layer.lineWidth = 1.5
        line1Layer.strokeColor = color.cgColor
        line1Layer.fillColor = UIColor.clear.cgColor
        line1Layer.path = line1Path.cgPath
        
        //左邊的造型線
        let line2 = "M\(25 * scale),\(36 * scale) C\(26 * scale),\(45 * scale) \(17 * scale),\(50 * scale) \(14 * scale),\(50 * scale)"
        let line2Path = UIBezierPath(pathString: line2)
        let line2Layer = CAShapeLayer()
        line2Layer.lineWidth = 1.5
        line2Layer.strokeColor = color.cgColor
        line2Layer.fillColor = UIColor.clear.cgColor
        line2Layer.path = line2Path.cgPath
        
        //中間的造型線
        let line3 = "M\(63 * scale),\(31 * scale) C\(66 * scale),\(48 * scale) \(76 * scale),\(50 * scale) \(83 * scale),\(51 * scale)"
        let line3Path = UIBezierPath(pathString: line3)
        let line3Layer = CAShapeLayer()
        line3Layer.lineWidth = 1.5
        line3Layer.strokeColor = color.cgColor
        line3Layer.fillColor = UIColor.clear.cgColor
        line3Layer.path = line3Path.cgPath
        
        //右側的造型線
        let line4 = "M\(74 * scale),\(37 * scale) C\(76 * scale),\(46 * scale) \(80 * scale),\(49 * scale) \(85 * scale),\(51 * scale)"
        let line4Path = UIBezierPath(pathString: line4)
        let line4Layer = CAShapeLayer()
        line4Layer.lineWidth = 1.5
        line4Layer.strokeColor = color.cgColor
        line4Layer.fillColor = UIColor.clear.cgColor
        line4Layer.path = line4Path.cgPath
        
        return [hair2Layer, faceLayer, hair1Layer, line1Layer, line2Layer, line3Layer, line4Layer]
    }
    
    /// 中分男
    static private func svgHairLayer_Male_CenterParting(sideLength: CGFloat, sliderPercentage: CGFloat, color: UIColor) -> [CAShapeLayer] {
        let scale: CGFloat = sideLength / 100
        let value = sliderPercentage * 18 * scale
        let edgePoint = sliderPercentage * 2.4 * scale
        
        //臉的弧形
        let face = "M\(17 * scale),\(30 * scale) L\(17 * scale),\(65 * scale) C\(17 * scale),\(70 * scale) \(22 * scale),\(92 * scale) \(51 * scale),\(94 * scale) M\(85 * scale),\(30 * scale) L\(85 * scale),\(65 * scale) C\(85 * scale),\(70 * scale) \(80 * scale),\(92 * scale) \(51 * scale),\(94 * scale)"
        let facePath = UIBezierPath(pathString: face)
        let faceLayer = CAShapeLayer()
        faceLayer.lineWidth = 1.5
        faceLayer.strokeColor = color.cgColor
        faceLayer.fillColor = UIColor.clear.cgColor
        faceLayer.path = facePath.cgPath
        
        //頭髮
        let hair = "M\(sideLength / 2),\(3 * scale) C\(73 * scale + edgePoint),\(5 * scale) \(85 * scale),\(15 * scale) \(86 * scale + edgePoint),\(35 * scale + value) C\(84 * scale),\(37 * scale + value) \(65 * scale),\(33 * scale + value) \(sideLength / 2),\(27 * scale) M\(sideLength / 2),\(3 * scale) C\(27 * scale - edgePoint),\(5 * scale) \(14 * scale),\(15 * scale) \(16 * scale - edgePoint),\(35 * scale + value) C\(18 * scale),\(37 * scale + value) \(36 * scale),\(33 * scale + value) \(sideLength / 2),\(27 * scale)"
        
        let hairPath = UIBezierPath(pathString: hair)
        let hairLayer = CAShapeLayer()
        hairLayer.lineWidth = 1.5
        hairLayer.strokeColor = color.cgColor
        hairLayer.fillColor = UIColor.white.cgColor
        hairLayer.path = hairPath.cgPath
        
        return [faceLayer, hairLayer]
    }
    
    /// 中分女
    static private func svgHairLayer_Female_CenterParting(sideLength: CGFloat, sliderPercentage: CGFloat, color: UIColor) -> [CAShapeLayer] {
        let scale: CGFloat = sideLength / 100
        let value = sliderPercentage * 50 * scale
        
        //臉的弧形
        let face = "M\(16 * scale),\(45 * scale) L\(16 * scale),\(55 * scale) C\(16 * scale),\(70 * scale) \(19 * scale),\(92 * scale) \(51 * scale),\(96 * scale) C\(80 * scale),\(92 * scale) \(83 * scale),\(70 * scale) \(83 * scale),\(55 * scale) L\(83 * scale),\(45 * scale)"
        let facePath = UIBezierPath(pathString: face)
        let faceLayer = CAShapeLayer()
        faceLayer.lineWidth = 1.5
        faceLayer.strokeColor = color.cgColor
        faceLayer.fillColor = UIColor.white.cgColor
        faceLayer.path = facePath.cgPath
        
        //頭髮
        let hair1 = "M\(sideLength / 2),\(3 * scale) C\(72 * scale),\(5 * scale) \(87 * scale),\(15 * scale) \(88 * scale),\(47 * scale) M\(sideLength / 2),\(3 * scale) C\(28 * scale),\(5 * scale) \(12 * scale),\(15 * scale) \(12 * scale),\(47 * scale)"

        let hair1Path = UIBezierPath(pathString: hair1)
        let hair1Layer = CAShapeLayer()
        hair1Layer.lineWidth = 1.5
        hair1Layer.strokeColor = color.cgColor
        hair1Layer.fillColor = UIColor.clear.cgColor
        hair1Layer.path = hair1Path.cgPath
        
        //頭髮下緣的造型線
        let hair2 = "M\(88 * scale),\(47 * scale) L\(88 * scale),\(53 * scale + value) L\(90 * scale),\(57 * scale + value) C\(80 * scale),\(55 * scale + value) \(82 * scale),\(41 * scale + value) \(80 * scale),\(57 * scale + value) C\(76 * scale),\(65 * scale + value) \(74 * scale),\(41 * scale + value) \(70 * scale),\(57 * scale + value) C\(66 * scale),\(65 * scale + value) \(64 * scale),\(41 * scale + value) \(60 * scale),\(57 * scale + value) C\(56 * scale),\(65 * scale + value) \(54 * scale),\(41 * scale + value) \(50 * scale),\(57 * scale + value) C\(46 * scale),\(65 * scale + value) \(44 * scale),\(41 * scale + value) \(40 * scale),\(57 * scale + value) C\(36 * scale),\(65 * scale + value) \(34 * scale),\(41 * scale + value) \(30 * scale),\(57 * scale + value) C\(26 * scale),\(65 * scale + value) \(24 * scale),\(41 * scale + value) \(20 * scale),\(57 * scale + value) C\(14 * scale),\(65 * scale + value) \(22 * scale),\(39 * scale + value) \(10 * scale),\(57 * scale + value) L\(12 * scale),\(45 * scale + value) L\(12 * scale),\(47 * scale)"
        let hair2Path = UIBezierPath(pathString: hair2)
        let hair2Layer = CAShapeLayer()
        hair2Layer.lineWidth = 1.5
        hair2Layer.strokeColor = color.cgColor
        hair2Layer.fillColor = UIColor.clear.cgColor
        hair2Layer.path = hair2Path.cgPath
        
        //中分的造型線
        let line1 = "M\(13 * scale),\(51 * scale) C\(35 * scale),\(50 * scale) \(44 * scale),\(45 * scale) \(49 * scale),\(32 * scale) C\(57 * scale),\(45 * scale) \(68 * scale),\(50 * scale) \(87 * scale),\(51 * scale)"
        let line1Path = UIBezierPath(pathString: line1)
        let line1Layer = CAShapeLayer()
        line1Layer.lineWidth = 1.5
        line1Layer.strokeColor = color.cgColor
        line1Layer.fillColor = UIColor.clear.cgColor
        line1Layer.path = line1Path.cgPath
        
        //左1的造型線
        let line2 = "M\(28 * scale),\(37 * scale) C\(26 * scale),\(46 * scale) \(22 * scale),\(49 * scale) \(17 * scale),\(51 * scale)"
        let line2Path = UIBezierPath(pathString: line2)
        let line2Layer = CAShapeLayer()
        line2Layer.lineWidth = 1.5
        line2Layer.strokeColor = color.cgColor
        line2Layer.fillColor = UIColor.clear.cgColor
        line2Layer.path = line2Path.cgPath
        
        //左2的造型線
        let line5 = "M\(39 * scale),\(31 * scale) C\(36 * scale),\(48 * scale) \(26 * scale),\(50 * scale) \(19 * scale),\(51 * scale)"
        let line5Path = UIBezierPath(pathString: line5)
        let line5Layer = CAShapeLayer()
        line5Layer.lineWidth = 1.5
        line5Layer.strokeColor = color.cgColor
        line5Layer.fillColor = UIColor.clear.cgColor
        line5Layer.path = line5Path.cgPath
        
        //右2的造型線
        let line3 = "M\(63 * scale),\(31 * scale) C\(66 * scale),\(48 * scale) \(76 * scale),\(50 * scale) \(83 * scale),\(51 * scale)"
        let line3Path = UIBezierPath(pathString: line3)
        let line3Layer = CAShapeLayer()
        line3Layer.lineWidth = 1.5
        line3Layer.strokeColor = color.cgColor
        line3Layer.fillColor = UIColor.clear.cgColor
        line3Layer.path = line3Path.cgPath
        
        //右1的造型線
        let line4 = "M\(74 * scale),\(37 * scale) C\(76 * scale),\(46 * scale) \(80 * scale),\(49 * scale) \(85 * scale),\(51 * scale)"
        let line4Path = UIBezierPath(pathString: line4)
        let line4Layer = CAShapeLayer()
        line4Layer.lineWidth = 1.5
        line4Layer.strokeColor = color.cgColor
        line4Layer.fillColor = UIColor.clear.cgColor
        line4Layer.path = line4Path.cgPath
        
        return [hair2Layer, faceLayer, hair1Layer, line1Layer, line2Layer, line3Layer, line4Layer, line5Layer]
    }
}

