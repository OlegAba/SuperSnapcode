//
//  ExportWallpaperViewController.swift
//  Live-Snap
//
//  Created by Baby on 1/18/18.
//  Copyright © 2018 Baby. All rights reserved.
//

import UIKit
import PhotosUI

class ExportWallpaperViewController: UIViewController, PHLivePhotoViewDelegate {
    
    var livePhotoPreviewView: PHLivePhotoView!
    var exportButton: UIButton!
    
    var livePhoto: LivePhoto!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.snapBlack
        view.isUserInteractionEnabled = false
        
        livePhotoPreviewView = PHLivePhotoView(frame: view.frame)
        livePhotoPreviewView.livePhoto = livePhoto.phLivePhoto
        livePhotoPreviewView.delegate = self
        view.addSubview(livePhotoPreviewView)
        
        exportButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        exportButton.setTitle("Export", for: .normal)
        exportButton.setTitleColor(UIColor.snapBlack, for: .normal)
        exportButton.setBackgroundImage(UIImage(color: UIColor.snapYellow, size: exportButton.frame.size), for: .normal)
        exportButton.setBackgroundImage(UIImage(color: UIColor.snapYellow.withAlphaComponent(0.75), size: exportButton.frame.size), for: .highlighted)
        exportButton.addTarget(self, action: #selector(exportButtonWasPressed), for: .touchUpInside)
    }
    
    func showPreview() {
        livePhotoPreviewView.startPlayback(with: .full)
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        if !view.subviews.contains(exportButton) {
            view.addSubview(exportButton)
            view.isUserInteractionEnabled = true
        }
    }
    
    @objc func exportButtonWasPressed() {
        livePhoto.writeToPhotoLibrary { (success: Bool) in
            if success {
                // transition to next phase
            } else {
                // show error alert
            }
        }
    }
}
