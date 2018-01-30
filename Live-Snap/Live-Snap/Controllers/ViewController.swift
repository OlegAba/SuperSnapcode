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
        
        view.backgroundColor = .white
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let redVC = FetchSnapcodeViewController()
        appDelegate.pageViewController?.setViewControllers([redVC], direction: .forward, animated: true, completion: { _ in
            redVC.showKeyboard()
        })
    }
}
