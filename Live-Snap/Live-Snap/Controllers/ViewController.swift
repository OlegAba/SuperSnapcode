//
//  ViewController.swift
//  Live-Snap
//
//  Created by Oleg Abalonski on 1/6/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let networkRequest = SnapcodeEndpointRequest(snapchatUsername: "x-oleg")
        
        networkRequest.start { (snapcode: UIImage?) in
            if let image = snapcode {
                print("we got an image")
                DispatchQueue.main.async {
                    let imageView = UIImageView(frame: self.view.frame)
                    imageView.image = image
                    imageView.contentMode = .scaleAspectFit
                    self.view.addSubview(imageView)
                }
            }
        }
    }
}
