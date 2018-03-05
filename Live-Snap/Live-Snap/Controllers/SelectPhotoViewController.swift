//
//  SelectPhotoViewController.swift
//  Live-Snap
//
//  Created by Oleg Abalonski on 1/13/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import UIKit
import Photos

class SelectPhotoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIToolbarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var collectionView: UICollectionView!
    var toolBar: UIToolbar!
    var currentAlbumLabel: UILabel!
    var tableView: UITableView!
    var activityIndicator: UIActivityIndicatorView!
    var statusBarView: UIView!
    var deniedLibraryPermissionLabel: UILabel!
    var goToUserSettingsButton: UIButton!
    
    var photoAlbums = [PhotoAlbum]()
    var photoThumbnails = [UIImage]()
    var currentAlbumName = "All Photos"
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.snapBlack
        if view.isIPhoneX() {
            view.frame.size.height -= 34.0
        }
        
        toolBar = UIToolbar(frame: CGRect(x: 0, y: view.frame.size.height - 45, width: view.frame.size.width, height: 45))
        toolBar.isTranslucent = false
        toolBar.barTintColor = UIColor.snapBlack
        
        let backBarButton = UIBarButtonItem(title: "Back", style:.plain, target: self, action: #selector(backButtonWasPressed))
        backBarButton.tintColor = UIColor.snapYellow
        
        let selectAlbumButton: UIBarButtonItem = UIBarButtonItem(title: "Albums", style:.plain, target: self, action: #selector(animateTableView))
        selectAlbumButton.tintColor = UIColor.snapYellow
        
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolBar.items = [backBarButton, flexibleSpaceBarButtonItem, selectAlbumButton]
        
        currentAlbumLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width * 0.5, height: 45))
        currentAlbumLabel.center = CGPoint(x: view.frame.width / 2, y: view.frame.height - toolBar.frame.height / 2)
        currentAlbumLabel.text = currentAlbumName
        currentAlbumLabel.textColor = .white
        currentAlbumLabel.textAlignment = .center
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: statusBarHeight, width: view.frame.width, height: view.frame.height - (statusBarHeight + toolBar.frame.height)), collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(SelectPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "SelectPhotoCollectionViewCellReuseIdentifier")
        collectionView.backgroundColor = UIColor.snapBlack
        collectionView.dataSource = self
        collectionView.delegate = self
        
        tableView = UITableView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height))
        tableView.backgroundColor = UIColor.snapBlack
        tableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: "AlbumTableViewCellReuseIdentifier")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor.snapYellow
        tableView.preservesSuperviewLayoutMargins = false
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
        tableView.isHidden = true
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        
        deniedLibraryPermissionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.75, height: 100))
        deniedLibraryPermissionLabel.center = view.center
        deniedLibraryPermissionLabel.textColor = UIColor.snapWhite
        deniedLibraryPermissionLabel.textAlignment = .center
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        deniedLibraryPermissionLabel.text = "\(appName) needs access to your photo library to import and export images. Please click the settings button below and enable access"
        deniedLibraryPermissionLabel.numberOfLines = 4
        
        goToUserSettingsButton = UIButton(frame: CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: 50))
        goToUserSettingsButton.setTitle("Settings", for: .normal)
        goToUserSettingsButton.setTitleColor(UIColor.snapBlack, for: .normal)
        goToUserSettingsButton.setBackgroundImage(UIImage(color: UIColor.snapYellow, size: goToUserSettingsButton.frame.size), for: .normal)
        goToUserSettingsButton.setBackgroundImage(UIImage(color: UIColor.snapYellow.withAlphaComponent(0.75), size: goToUserSettingsButton.frame.size), for: .highlighted)
        goToUserSettingsButton.addTarget(self, action: #selector(goToSettingsButtonWasPressed), for: .touchUpInside)
        
        statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarView.backgroundColor = UIColor.snapBlack
        
        ImageManager.shared.requestPhotoLibraryPermission { (status: Bool) in
            DispatchQueue.main.async {
                
                self.goToUserSettingsButton.removeFromSuperview()
                self.deniedLibraryPermissionLabel.removeFromSuperview()
                
                if status == true {
                    self.view.addSubview(self.deniedLibraryPermissionLabel)
                    self.view.addSubview(self.goToUserSettingsButton)
                } else {
                    self.view.addSubview(self.collectionView)
                    self.view.addSubview(self.activityIndicator)
                    self.view.addSubview(self.tableView)
                    self.view.addSubview(self.statusBarView)
                    self.view.addSubview(self.toolBar)
                    self.view.addSubview(self.currentAlbumLabel)
                }
            }
            self.getAllPhotoThumbnails()
        }
        
    }
    
    func getAllPhotoThumbnails() {
        DispatchQueue.main.sync {
            view.isUserInteractionEnabled = false
            activityIndicator.startAnimating()
        }
        
        photoAlbums = ImageManager.shared.grabAllPhotoAlbums()
        for photoAlbum in photoAlbums {
            if photoAlbum.name == "All Photos" {
                ImageManager.shared.grabThumbnailsFromPhotoAlbum(photoAlbum: photoAlbum, completion: { (thumbnails) in
                    DispatchQueue.main.async {
                        if let thumbnails = thumbnails {
                            self.photoThumbnails = thumbnails
                            self.collectionView.reloadData()
                            self.tableView.reloadData()
                            self.activityIndicator.stopAnimating()
                            self.view.isUserInteractionEnabled = true
                        }
                    }
                })
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoThumbnails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectPhotoCollectionViewCellReuseIdentifier", for: indexPath) as? SelectPhotoCollectionViewCell else { return UICollectionViewCell() }
        cell.setImage(image: photoThumbnails[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 2.0
        let numberOfItermsPerRow: CGFloat = 3.0
        let sizePerItem = (view.frame.width - (2 * spacing)) / numberOfItermsPerRow
        return CGSize(width: sizePerItem, height: sizePerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for photoAlbum in photoAlbums {
            if photoAlbum.name == currentAlbumName {
                let asset = photoAlbum.assets.object(at: indexPath.row)
                ImageManager.shared.grabFullPhotoFromAsset(asset: asset, completion: { (image: UIImage?) in
                    if let image = image {
                        let cropWallpaperViewController = CropWallpaperViewController()
                        cropWallpaperViewController.imageToCrop = image
                        System.shared.appDelegate().pageViewController?.setViewControllers([cropWallpaperViewController], direction: .forward, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumTableViewCellReuseIdentifier", for: indexPath) as? AlbumTableViewCell else { return UITableViewCell()}
        cell.setText(photoAlbums[indexPath.row].name)
        cell.setAlbumCount(photoAlbums[indexPath.row].assets.count)
        
        if (photoAlbums.count - 1) == indexPath.row {
            let initialSelectionIndexPath = IndexPath(row: 0, section: 0)
            self.tableView.selectRow(at: initialSelectionIndexPath, animated: true, scrollPosition: .none)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentCell = self.tableView.cellForRow(at: indexPath) as? AlbumTableViewCell, let selectedAlbumName = currentCell.albumTitleLabel.text else { return }
        guard selectedAlbumName != currentAlbumName else { self.animateTableView(); return }
        
        currentAlbumName = selectedAlbumName
        
        DispatchQueue.global(qos: .userInitiated).sync {
            self.animateTableView()
            self.currentAlbumLabel.text = selectedAlbumName
            self.photoThumbnails = []
            self.collectionView.reloadData()
            self.activityIndicator.startAnimating()
        }
        
        DispatchQueue.main.async {
            for photoAlbum in self.photoAlbums {
                if photoAlbum.name == selectedAlbumName {
                    ImageManager.shared.grabThumbnailsFromPhotoAlbum(photoAlbum: photoAlbum, completion: { (thumbnails: [UIImage]?) in
                        if let thumbnails = thumbnails {
                            self.photoThumbnails = thumbnails
                            self.collectionView.reloadData()
                            self.activityIndicator.stopAnimating()
                        }
                    })
                }
            }
            
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func animateTableView() {
        view.isUserInteractionEnabled = false
        
        if self.tableView.isHidden {
            self.tableView.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.tableView.frame = CGRect(x: 0, y: self.statusBarHeight, width: self.view.frame.width, height: self.view.frame.height)
            }, completion: { (finished: Bool) in
                self.view.isUserInteractionEnabled = true
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.tableView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
            }, completion: { (finished: Bool) in
                self.tableView.isHidden = true
                self.view.isUserInteractionEnabled = true
            })
        }
    }
    
    @objc func backButtonWasPressed() {
        let fetchSnapcodeViewController = FetchSnapcodeViewController()
        
        System.shared.appDelegate().pageViewController?.setViewControllers([fetchSnapcodeViewController], direction: .reverse, animated: true, completion: nil)
    }
    
    @objc func goToSettingsButtonWasPressed() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }
    
}

