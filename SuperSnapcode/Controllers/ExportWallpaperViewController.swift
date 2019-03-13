//
//  ExportWallpaperViewController.swift
//  Live-Snap
//
//  Created by Oleg Abalonski on 1/18/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import UIKit
import PhotosUI
import AVKit
import JGProgressHUD
import LPLivePhotoGenerator

class ExportWallpaperViewController: UIViewController, PHLivePhotoViewDelegate {
    
    var livePhotoPreviewView: PHLivePhotoView!
    var activityIndicatorForCreatingLivePhoto: LoadingIndicatorView!
    var toolBar: UIToolbar!
    var forceTouchNotifierLabel: UILabel!
    var forceTouchNotifierImageView: UIImageView!
    var saveSuccessPopUpView: UIView!
    var saveSuccessBackgroundView: UIView!
    var saveErrorIndicator: JGProgressHUD!
    
    var livePhoto: LPLivePhoto!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.snapBlack
        view.isUserInteractionEnabled = false
        
        livePhotoPreviewView = PHLivePhotoView(frame: view.frame)
        livePhotoPreviewView.delegate = self
        view.addSubview(livePhotoPreviewView)
        
        activityIndicatorForCreatingLivePhoto = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.5, height: view.frame.height * 0.1), text: "Generating Live Photo", color: UIColor.snapWhite)
        activityIndicatorForCreatingLivePhoto.center = view.center
        view.addSubview(activityIndicatorForCreatingLivePhoto)
        
        toolBar = UIToolbar(frame: CGRect(x: 0, y: view.frame.size.height, width: view.frame.size.width, height: 45))
        toolBar.isTranslucent = false
        toolBar.barTintColor = UIColor.snapBlack
        toolBar.isHidden = true
        
        let backBarButton = UIBarButtonItem(title: "Back", style:.plain, target: self, action: #selector(backButtonWasPressed))
        backBarButton.tintColor = UIColor.snapYellow
        
        let selectAlbumButton: UIBarButtonItem = UIBarButtonItem(title: "Save", style:.plain, target: self, action: #selector(saveButtonWasPressed))
        selectAlbumButton.tintColor = UIColor.snapYellow

        toolBar.items = [backBarButton, UIBarButtonItem.flexibleSpace(), selectAlbumButton]
        
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
        
        saveSuccessPopUpView = SaveSuccessPopUpView(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.75, height: 211))
        saveSuccessPopUpView.center.x = view.center.x
        saveSuccessPopUpView.frame.origin.y = view.frame.height
        
        saveSuccessBackgroundView = UIView(frame: view.frame)
        saveSuccessBackgroundView.backgroundColor = .black
        saveSuccessBackgroundView.alpha = 0
        
        saveErrorIndicator = JGProgressHUD(style: .dark)
        saveErrorIndicator.indicatorView = JGProgressHUDErrorIndicatorView()
        saveErrorIndicator.textLabel.text = "Failed to save!\nPlease try again"
        saveErrorIndicator.shadow = JGProgressHUDShadow()
        saveErrorIndicator.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        
        view.addSubview(toolBar)
        view.addSubview(forceTouchNotifierLabel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activityIndicatorForCreatingLivePhoto.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.createLivePhoto()
        }
    }

    
    func createLivePhoto() {
        FileManager.default.clearDocumentsDirectory()
        let livePhotoGenerator = GenerateLiveWallpaperWithBarcode(fileName: "live_wallpaper", wallpaperImage: System.shared.wallpaper!, barcodeImage: System.shared.snapcode!)
        
        livePhotoGenerator.create { (livePhoto: LPLivePhoto?) in
            if let livePhoto = livePhoto {
                DispatchQueue.main.async {
                    self.livePhoto = livePhoto
                    self.livePhotoPreviewView.livePhoto = livePhoto.phLivePhoto
                    self.activityIndicatorForCreatingLivePhoto.stopAnimating()
                    self.livePhotoPreviewView.startPlayback(with: .full)
                }
            } else {
                self.backButtonWasPressed()
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
    
    func showSaveSuccessPopUpView() {
        view.isUserInteractionEnabled = false
        view.addSubview(saveSuccessBackgroundView)
        view.addSubview(saveSuccessPopUpView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
            self.saveSuccessPopUpView.center.y = self.view.center.y
            self.saveSuccessBackgroundView.alpha = 0.75
        }) { (finished: Bool) in
            self.view.isUserInteractionEnabled = true
        }
    }
    
    @objc func saveButtonWasPressed() {
        view.isUserInteractionEnabled = false
        
        livePhoto.writeToPhotoLibrary { (livePhoto: LPLivePhoto, error: Error?) in
            DispatchQueue.main.sync {
                if let error = error {
                    print(error)
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
                } else {
                    self.showSaveSuccessPopUpView()
                }
            }
        }
        
    }
    
}
