import UIKit

class IconButton: UIButton {
    
    var icon: UIImageView!
    var label: UILabel!
    
    var text: String!
    var textColor: UIColor!
    var fontSize: Float!
    var spaceBetween: Float!
    
    init(frame: CGRect, icon: UIImageView, text: String, textColor: UIColor, fontSize: Float, spaceBetween: Float) {
        super.init(frame: frame)
        
        self.icon = icon
        self.text = text
        self.textColor = textColor
        self.fontSize = fontSize
        self.spaceBetween = spaceBetween
        
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayout() {
        label = UILabel()
        label.text = text
        label.font = label.font.withSize(CGFloat(fontSize))
        label.sizeToFit()
        label.textColor = textColor
        
        let iconOriginX = (frame.width - (label.frame.width + CGFloat(spaceBetween) + icon.frame.width)) / 2
        icon.frame.origin.x = iconOriginX
        icon.center.y = center.y
        
        label.frame.origin.x = icon.frame.maxX + CGFloat(spaceBetween)
        label.center.y = center.y
        
        addSubview(icon)
        addSubview(label)
    }
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1.0
        }
    }
}
