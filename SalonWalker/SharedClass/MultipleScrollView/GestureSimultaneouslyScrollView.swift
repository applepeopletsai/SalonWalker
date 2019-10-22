//
//  GestureSimultaneouslyScrollView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/18.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class GestureSimultaneouslyScrollView: UIScrollView {}

extension GestureSimultaneouslyScrollView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
