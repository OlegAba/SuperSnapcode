//
//  ExportWallpaperViewController.swift
//  Live-Snap
//
//  Created by Baby on 1/18/18.
//  Copyright © 2018 Baby. All rights reserved.
//

import UIKit
import PhotosUI
import AVKit
import JGProgressHUD

class ExportWallpaperViewController: UIViewController, PHLivePhotoViewDelegate {
    
    var livePhotoPreviewView: PHLivePhotoView!
    var activityIndicatorForCreatingLivePhoto: JGProgressHUD!
    var toolBar: UIToolbar!
    var forceTouchNotifierLabel: UILabel!
    var forceTouchNotifierImageView: UIImageView!
    var saveSuccessIndicator: JGProgressHUD!
    var saveErrorIndicator: JGProgressHUD!
    
    var livePhoto: LivePhoto!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.snapBlack
        view.isUserInteractionEnabled = false
        
        livePhotoPreviewView = PHLivePhotoView(frame: view.frame)
        livePhotoPreviewView.delegate = self
        view.addSubview(livePhotoPreviewView)
        
        activityIndicatorForCreatingLivePhoto = JGProgressHUD(style: .dark)
        activityIndicatorForCreatingLivePhoto.contentView.backgroundColor = UIColor.snapBlack
        activityIndicatorForCreatingLivePhoto.textLabel.text = "Generating Live Photo"
        activityIndicatorForCreatingLivePhoto.show(in: view)
        
        toolBar = UIToolbar(frame: CGRect(x: 0, y: view.frame.size.height, width: view.frame.size.width, height: 45))
        toolBar.isTranslucent = false
        toolBar.barTintColor = UIColor.snapBlack
        toolBar.isHidden = true
        
        let backBarButton = UIBarButtonItem(title: "Back", style:.plain, target: self, action: #selector(backButtonWasPressed))
        backBarButton.tintColor = UIColor.snapYellow
        
        let selectAlbumButton: UIBarButtonItem = UIBarButtonItem(title: "Save", style:.plain, target: self, action: #selector(saveButtonWasPressed))
        selectAlbumButton.tintColor = UIColor.snapYellow
        
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolBar.items = [backBarButton, flexibleSpaceBarButtonItem, selectAlbumButton]
        
        let forceTouchNotifierText: String = {
            if self.traitCollection.forceTouchCapability == UIForceTouchCapability.available {
                return "Force Touch"
            } else {
                return "Long Press"
            }
        }()
        
        forceTouchNotifierLabel = UILabel()
        forceTouchNotifierLabel.text = forceTouchNotifierText + " to Preview"
        forceTouchNotifierLabel.sizeToFit()
        forceTouchNotifierLabel.center = toolBar.center
        forceTouchNotifierLabel.textColor = .white
        forceTouchNotifierLabel.textAlignment = .center
        forceTouchNotifierLabel.isHidden = true
        
        saveSuccessIndicator = JGProgressHUD(style: .dark)
        saveSuccessIndicator.indicatorView = JGProgressHUDSuccessIndicatorView()
        saveSuccessIndicator.textLabel.text = "Saved"
        saveSuccessIndicator.shadow = JGProgressHUDShadow()
        saveSuccessIndicator.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        
        saveErrorIndicator = JGProgressHUD(style: .dark)
        saveErrorIndicator.indicatorView = JGProgressHUDErrorIndicatorView()
        saveErrorIndicator.textLabel.text = "Failed to save!\nPlease try again"
        saveErrorIndicator.shadow = JGProgressHUDShadow()
        saveErrorIndicator.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        
        view.addSubview(toolBar)
        view.addSubview(forceTouchNotifierLabel)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.createLivePhoto()
        }
        
    }
    
    func createLivePhoto() {
        FileManager.default.clearDocumentsDirectory()
        let livePhotoGenerator = GenerateLiveWallpaperWithBarcode(fileName: "live_wallpaper", wallpaperImage: System.shared.wallpaper!, barcodeImage: System.shared.snapcode!)
        livePhotoGenerator.create { (livePhoto: LivePhoto?) in
            if let livePhoto = livePhoto {
                DispatchQueue.main.async {
                    self.livePhoto = livePhoto
                    self.livePhotoPreviewView.livePhoto = livePhoto.phLivePhoto
                    self.activityIndicatorForCreatingLivePhoto.dismiss(animated: false)
                    self.activityIndicatorForCreatingLivePhoto.animation.animationFinished()
                    self.livePhotoPreviewView.startPlayback(with: .full)
                }
            }
        }
        
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        if toolBar.isHidden {
            toolBar.isHidden = false
            forceTouchNotifierLabel.isHidden = false
            animateToolBarAndLivePhotoView()
            view.isUserInteractionEnabled = true
        }
    }
    
    func animateToolBarAndLivePhotoView() {
        let iPhoneXSafeAreaBackgroundView = UIView(frame: CGRect(x: 0, y: self.toolBar.frame.origin.y + 45.0, width: self.view.frame.width, height: 34.0))
        iPhoneXSafeAreaBackgroundView.backgroundColor = UIColor.snapBlack
        
        if self.view.isIPhoneX() {
            self.view.frame.size.height -= 34.0
            self.view.addSubview(iPhoneXSafeAreaBackgroundView)
        }
        
        UIView.animate(withDuration: 0.6, animations: {
            
            self.toolBar.frame = CGRect(x: 0, y: self.view.frame.size.height - 45, width: self.view.frame.size.width, height: 45)
            iPhoneXSafeAreaBackgroundView.frame = CGRect(x: 0, y: self.toolBar.frame.origin.y + self.toolBar.frame.size.height, width: self.view.frame.width, height: 34.0)
            
            self.forceTouchNotifierLabel.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - self.toolBar.frame.height / 2)
            
            let orginalLivePhotoViewRect = self.livePhotoPreviewView.frame
            let newLivePhotoViewRect = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: self.view.frame.size.width, height: self.view.frame.size.height - (self.toolBar.frame.size.height + UIApplication.shared.statusBarFrame.height))
            let yOffset = orginalLivePhotoViewRect.midY - newLivePhotoViewRect.midY
            
            let orginalTransform = self.livePhotoPreviewView.transform
            let transformScale = newLivePhotoViewRect.size.height / orginalLivePhotoViewRect.size.height
            let scaledTransform = orginalTransform.scaledBy(x: transformScale, y: transformScale)
            let scaledTransformAndTranslate = scaledTransform.translatedBy(x: 0.0, y: -yOffset)
            self.livePhotoPreviewView.transform = scaledTransformAndTranslate
            
            if self.view.isIPhoneX() {
                self.view.frame.size.height += 34.0
            }
        })
    }
    
    @objc func backButtonWasPressed() {
        let cropWallpaperViewController = CropWallpaperViewController()
        cropWallpaperViewController.imageToCrop = System.shared.imageToCrop!
        
        System.shared.appDelegate().pageViewController?.setViewControllers([cropWallpaperViewController], direction: .reverse, animated: true, completion: nil)
    }
    
    @objc func saveButtonWasPressed() {
        view.isUserInteractionEnabled = false
        
        livePhoto.writeToPhotoLibrary { (success: Bool) in
            DispatchQueue.main.sync {
                if success {
                        self.saveSuccessIndicator.show(in: self.view, animated: true)
                        self.saveSuccessIndicator.dismiss(afterDelay: 1.5, animated: true)
                        self.saveSuccessIndicator.animation.animationFinished()
                        let fetchSnapcodeViewController = FetchSnapcodeViewController()
                    
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                            System.shared.imageToCrop = nil
                            System.shared.snapcode = nil
                            System.shared.wallpaper = nil
                            System.shared.appDelegate().pageViewController?.setViewControllers([fetchSnapcodeViewController], direction: .forward, animated: true, completion: nil)
                        }
                } else {
                        print("Error exporting livePhoto")
                        self.saveErrorIndicator.show(in: self.view, animated: true)
                        self.saveErrorIndicator.dismiss(afterDelay: 1.5, animated: true)
                        self.saveErrorIndicator.animation.animationFinished()
                        let fetchSnapcodeViewController = FetchSnapcodeViewController()
                    
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                            System.shared.imageToCrop = nil
                            System.shared.snapcode = nil
                            System.shared.wallpaper = nil
                            System.shared.appDelegate().pageViewController?.setViewControllers([fetchSnapcodeViewController], direction: .forward, animated: true, completion: nil)
                        }
                }
            }
        }
    }
    
    
    
}

