//
//  UIView+.swift
//  Live-Snap
//
//  Created by Baby on 1/15/18.
//  Copyright © 2018 Baby. All rights reserved.
//

import UIKit

extension UIView {
    
    func topCenter() -> CGPoint {
        return CGPoint(x: frame.origin.x + frame.width / 2.0, y: frame.origin.y)
    }
    
    func bottomCenter() -> CGPoint {
        return CGPoint(x: frame.origin.x + frame.width / 2.0, y: frame.origin.y + frame.height)
    }
    
    func leftCenter() -> CGPoint {
        return CGPoint(x: frame.origin.x, y: frame.origin.y + frame.height / 2.0)
    }
    
    func rightCenter() -> CGPoint {
        return CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y + frame.height / 2.0)
    }
    
    func isIPhoneX() {
        if UIScreen.main.nativeBounds.height == 2436 {
            self.frame.size.height = self.frame.size.height - 34.0
        }
    }
    
}
