import UIKit

extension UILabel {
    
    func setTextString(string: String, withLineSpacing lineSpacing: CGFloat) {
        let attributedString = NSMutableAttributedString(string: string)
        let stringStyle = NSMutableParagraphStyle()
        stringStyle.lineSpacing = lineSpacing
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: stringStyle, range: NSRange(location: 0, length: string.count))
        
        self.attributedText = attributedString
    }
    
}
