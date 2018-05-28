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
    var saveSuccessPopUpView: UIView!
    var saveSuccessBackgroundView: UIView!
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
        
        saveSuccessPopUpView = SaveSuccessPopUpView(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.75, height: 207))
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
            } else {
//TODO: Handle failure Case
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
        
        livePhoto.writeToPhotoLibrary { (success: Bool) in
            DispatchQueue.main.sync {
                if success {
                    self.showSaveSuccessPopUpView()
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

fileprivate class SaveSuccessPopUpView: UIView {
    
    var successIconImageView: UIImageView!
    var successLabel: UILabel!
    var lineBreakOneView: UIView!
    var goToPhotosImageView: UIImageView!
    var goToPhotosIconButton: UIButton!
    var lineBreakTwoView: UIView!
    var lineBreakThreeView: UIView!
    var newImageView: UIImageView!
    var newIconButton: UIButton!
    var rateImageView: UIImageView!
    var rateIconButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayout() {
        backgroundColor = UIColor.snapBlack
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        successIconImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 40, height: 40))
        successIconImageView.center.x = center.x
        successIconImageView.frame.origin.y = frame.origin.y + 10.0
        let successIconImage = UIImage(named: "success")?.withRenderingMode(.alwaysTemplate)
        successIconImageView.image = successIconImage
        successIconImageView.tintColor = UIColor.snapWhite
        successIconImageView.contentMode = .scaleAspectFill
        
        successLabel = UILabel()
        successLabel.text = "Success"
        successLabel.font = successLabel.font.withSize(15)
        successLabel.sizeToFit()
        successLabel.center.x = center.x
        successLabel.frame.origin.y = successIconImageView.frame.maxY + 5.0
        successLabel.textColor = UIColor.snapWhite
        
        lineBreakOneView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: 1.0))
        lineBreakOneView.center.x = center.x
        lineBreakOneView.frame.origin.y = successLabel.frame.maxY + 15.0
        lineBreakOneView.backgroundColor = UIColor.black
        
        goToPhotosImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18.0, height: 18.0))
        let openWallpaperSettingsImage = UIImage(named: "open")?.withRenderingMode(.alwaysTemplate)
        goToPhotosImageView.image = openWallpaperSettingsImage
        goToPhotosImageView.tintColor = UIColor.snapYellow
        goToPhotosImageView.contentMode = .scaleAspectFill
        
        goToPhotosIconButton = IconButton(icon: goToPhotosImageView, text: "Go to Photos", textColor: UIColor.snapYellow, fontSize: 15.0, spaceBetween: 10.0)
        goToPhotosIconButton.center.x = center.x
        goToPhotosIconButton.frame.origin.y = lineBreakOneView.frame.maxY + 20.0
        goToPhotosIconButton.addTarget(self, action: #selector(goToPhotosButtonWasPressed), for: .touchUpInside)
        
        lineBreakTwoView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: 1.0))
        lineBreakTwoView.center.x = center.x
        lineBreakTwoView.frame.origin.y = goToPhotosIconButton.frame.maxY + 20.0
        lineBreakTwoView.backgroundColor = .black
        
        lineBreakThreeView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 1.0, height: lineBreakTwoView.frame.origin.y - lineBreakOneView.frame.origin.y))
        lineBreakThreeView.center.x = center.x
        lineBreakThreeView.frame.origin.y = lineBreakTwoView.frame.maxY
        lineBreakThreeView.backgroundColor = .black
        
        newImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18.0, height: 18.0))
        let newImage = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
        newImageView.image = newImage
        newImageView.tintColor = UIColor.snapYellow
        newImageView.contentMode = .scaleAspectFill
        
        newIconButton = IconButton(icon: newImageView, text: "New", textColor: UIColor.snapYellow, fontSize: 15.0, spaceBetween: 10.0)
        newIconButton.center.x = center.x - (frame.width / 4)
        newIconButton.frame.origin.y = lineBreakTwoView.frame.maxY + 20.0
        newIconButton.addTarget(self, action: #selector(newButtonWasPressed), for: .touchUpInside)
        
        rateImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18.0, height: 18.0))
        let rateImage = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
        rateImageView.image = rateImage
        rateImageView.tintColor = UIColor.snapYellow
        rateImageView.contentMode = .scaleAspectFill
        
        rateIconButton = IconButton(icon: rateImageView, text: "Rate App", textColor: UIColor.yellow, fontSize: 15.0, spaceBetween: 10.0)
        rateIconButton.center.x = center.x + (frame.width / 4)
        rateIconButton.frame.origin.y = lineBreakTwoView.frame.maxY + 20.0
        rateIconButton.addTarget(self, action: #selector(rateButtonWasPressed), for: .touchUpInside)
        
        addSubview(successIconImageView)
        addSubview(successLabel)
        addSubview(lineBreakOneView)
        addSubview(goToPhotosIconButton)
        addSubview(lineBreakTwoView)
        addSubview(lineBreakThreeView)
        addSubview(newIconButton)
        addSubview(rateIconButton)
    }
    
    
    @objc func goToPhotosButtonWasPressed() {
        let photoLibraryURL = "photos-redirect://"
        
        if let url = URL(string: photoLibraryURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func newButtonWasPressed() {
        System.shared.imageToCrop = nil
        System.shared.snapcode = nil
        System.shared.wallpaper = nil
        
        let fetchSnapcodeViewController = FetchSnapcodeViewController()
    System.shared.appDelegate().pageViewController?.setViewControllers([fetchSnapcodeViewController], direction: .forward, animated: true, completion: nil)
    }
    
    @objc func rateButtonWasPressed() {
        let appID = ""
//TODO: Add App ID when published to store
        let appReviewURL = "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appID)"
        
        guard let url = URL(string: appReviewURL), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
    }
    
}

