//
//  IconButton.swift
//  Live-Snap
//
//  Created by Oleg Abalonski on 5/14/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import UIKit

class IconButton: UIButton {
    
    var icon: UIImageView!
    var label: UILabel!
    
    init(icon: UIImageView, text: String, textColor: UIColor, fontSize: Float, spaceBetween: Float) {
        self.icon = icon
        
        label = UILabel()
        label.text = text
        label.font = label.font.withSize(CGFloat(fontSize))
        label.sizeToFit()
        label.textColor = textColor
        
        let largerHeight = icon.frame.height > label.frame.height ? icon.frame.height : label.frame.height
        
        super.init(frame: CGRect(x: 0, y: 0, width: icon.frame.width + CGFloat(spaceBetween) + label.frame.width, height: largerHeight))
        
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayout() {
        icon.frame.origin.x = 0
        icon.center.y = center.y
        
        label.frame.origin.x = frame.width - label.frame.width
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
