//
//  System.swift
//  Live-Snap
//
//  Created by Baby on 1/21/18.
//  Copyright © 2018 Baby. All rights reserved.
//

import UIKit

class System {
    
    static let shared = System()
    
    var wallpaper: UIImage?
    var snapcode: UIImage?
    
    func appDelegate() -> AppDelegate {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return AppDelegate() }
        return appDelegate
    }
    
}
