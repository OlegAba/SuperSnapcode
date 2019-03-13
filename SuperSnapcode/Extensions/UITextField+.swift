import UIKit

extension UITextField {
    
    func setBottomUnderline(color: UIColor, lineWidth: Double) {
        borderStyle = .none
        
        layer.backgroundColor = backgroundColor?.cgColor
        
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: lineWidth)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 0.0
    }
    
}
