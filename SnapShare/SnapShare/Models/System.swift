//
//  System.swift
//  Live-Snap
//
//  Created by Oleg Abalonski on 1/21/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import UIKit

class System {
    
    static let shared = System()
    
    var imageToCrop: UIImage?
    var wallpaper: UIImage?
    var snapcode: UIImage?
    
    let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    
    func appDelegate() -> AppDelegate {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return AppDelegate() }
        return appDelegate
    }
}
