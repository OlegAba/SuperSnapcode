//
//  UIView+.swift
//  Live-Snap
//
//  Created by Oleg Abalonski on 1/15/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
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
    
    func isIPhoneX() -> Bool {
        if UIScreen.main.nativeBounds.height == 2436 {
            return true
        } else {
            return false
        }
    }
    
}
