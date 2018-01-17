//
//  CropWallpaperViewController.swift
//  Live-Snap
//
//  Created by Baby on 1/15/18.
//  Copyright © 2018 Baby. All rights reserved.
//

import UIKit
import CropViewController

class CropWallpaperViewController: UIViewController, CropViewControllerDelegate {
    
    var imageToCrop: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.snapBlack
        
        let cropViewController = CropViewController(image: imageToCrop)
        cropViewController.delegate = self
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.customAspectRatio = view.frame.size
        cropViewController.toolbar.clampButtonHidden = true
        cropViewController.toolbar.rotateClockwiseButtonHidden = true
        cropViewController.toolbar.rotateCounterclockwiseButtonHidden = true
        cropViewController.toolbar.resetButton.isHidden = true
        cropViewController.toolbar.subviews[0].backgroundColor = UIColor.snapBlack
        cropViewController.cropView.subviews[1].backgroundColor = UIColor.snapBlack
        cropViewController.toolbar.cancelTextButton.setTitleColor(UIColor.snapYellow, for: .normal)
        cropViewController.toolbar.doneTextButton.setTitleColor(UIColor.snapYellow, for: .normal)
        cropViewController.view.backgroundColor = UIColor.snapBlack
        cropViewController.cropView.backgroundColor = UIColor.snapBlack
        
        addChildViewController(cropViewController)
        cropViewController.view.frame = CGRect(x: 0, y: 20, width: view.frame.width, height: view.frame.height - 20)
        view.addSubview(cropViewController.view)
        cropViewController.didMove(toParentViewController: self)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        // transition to previous view
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // transition to next view
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
