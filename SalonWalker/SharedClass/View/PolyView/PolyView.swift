//
//  PolyView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/5/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class PolyView: UIView {

    private var designerPath = UIBezierPath()
    private var providerPath = UIBezierPath()
    private var designerAction: actionClosure?
    private var providerAction: actionClosure?
    
    init(frame: CGRect, designerPoints: [CGPoint], providerPoints: [CGPoint], designerAction:  @escaping actionClosure, providerAction: @escaping actionClosure) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.designerAction = designerAction
        self.providerAction = providerAction
        
        designerPath.move(to: designerPoints[0])
        providerPath.move(to: providerPoints[0])
        for index in 1..<designerPoints.count {
            designerPath.addLine(to: designerPoints[index])
            providerPath.addLine(to: providerPoints[index])
        }
        
        designerPath.close()
        providerPath.close()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            
            if designerPath.contains(point) {
                designerAction?()
            }
            
            if providerPath.contains(point) {
                providerAction?()
            }
        }
    }
    
}
