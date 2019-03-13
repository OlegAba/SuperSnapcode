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
        let screenHeight = UIScreen.main.nativeBounds.height
        if screenHeight == 2688.0 || // iPhone XS Max
           screenHeight == 2436.0 || // iPhone X/S
           screenHeight == 1792.0 {  // iPhone XR
            return true
        } else {
            return false
        }
    }
    
}
