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
    var tableView: UITableView!
    var containerView: UIView!
    var progressView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    
    var photoAlbums = [PhotoAlbum]()
    var photoThumbnails = [UIImage]()
    var currentAlbumName = "All Photos"
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: statusBarHeight, width: view.frame.width, height: view.frame.height - 118), collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(SelectPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "SelectPhotoCollectionViewCellReuseIdentifier")
        collectionView.backgroundColor = UIColor.snapBlack
        collectionView.dataSource = self
        collectionView.delegate = self
        
        toolBar = UIToolbar(frame: CGRect(x: 0, y: view.frame.size.height - 54, width: view.frame.size.width, height: 50))
        toolBar.layer.position = CGPoint(x: view.frame.width / 2, y: view.frame.height - 50)
        toolBar.isTranslucent = false
        toolBar.barTintColor = UIColor.snapBlack
        
        let backBarButton = UIBarButtonItem(title: "Back", style:.plain, target: self, action: nil)
        backBarButton.tintColor = UIColor.snapYellow
        
        let currentAlbumButton = UIBarButtonItem(title: "All Photos", style:.plain, target: self, action: nil)
        currentAlbumButton.tintColor = UIColor.snapWhite
        
        let selectAlbumButton: UIBarButtonItem = UIBarButtonItem(title: "Albums", style:.plain, target: self, action: #selector(animateTableView))
        selectAlbumButton.tintColor = UIColor.snapYellow
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        toolBar.items = [backBarButton, flexibleSpace, currentAlbumButton, flexibleSpace, selectAlbumButton]
        
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
        
        containerView = UIView()
        progressView = UIView()
        activityIndicator = UIActivityIndicatorView()
 
 
        view.addSubview(collectionView)
        view.addSubview(tableView)
        view.addSubview(toolBar)

        getAllPhotoThumbnails()
    }
    
    func getAllPhotoThumbnails() {
        photoAlbums = ImageManager.shared.grabAllPhotoAlbums()
        for photoAlbum in photoAlbums {
            if photoAlbum.name == "All Photos" {
                ImageManager.shared.grabThumbnailsFromPhotoAlbum(photoAlbum: photoAlbum, completion: { (thumbnails) in
                    DispatchQueue.main.async {
                        if let thumbnails = thumbnails {
                            self.photoThumbnails = thumbnails
                            self.collectionView.reloadData()
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
                        self.present(cropWallpaperViewController, animated: true, completion: nil)
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentCell = self.tableView.cellForRow(at: indexPath) as? AlbumTableViewCell, let selectedAlbumName = currentCell.albumTitleLabel.text else { return }
        guard selectedAlbumName != currentAlbumName else { self.animateTableView(); return }
        
        currentAlbumName = selectedAlbumName
        
        DispatchQueue.global(qos: .userInitiated).sync {
            self.animateTableView()
            
            showActivityIndicator()
        
        }
        
        DispatchQueue.main.async {
            
            for photoAlbum in self.photoAlbums {
                if photoAlbum.name == selectedAlbumName {
                    ImageManager.shared.grabThumbnailsFromPhotoAlbum(photoAlbum: photoAlbum, completion: { (thumbnails: [UIImage]?) in
                        if let thumbnails = thumbnails {
                            self.photoThumbnails = thumbnails
                            self.collectionView.reloadData()
                            if let toolbarItems = self.toolBar.items, toolbarItems.count >= 2 {
                                toolbarItems[2].title = selectedAlbumName
                            }
                            //self.activityIndicatorView.stopAnimating()
                            self.hideActivityIndicator()
                            
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
    
    func showActivityIndicator() {
        containerView.frame = view.frame
        containerView.center = view.center
        //containerView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
        
        
        progressView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        progressView.center = view.center
        progressView.backgroundColor = UIColor(red: 21 / 255.0, green: 25 / 255.0, blue: 28 / 255.0, alpha: 0.7)
        progressView.layer.borderWidth = 0.5
        progressView.layer.borderColor = UIColor.snapYellow.cgColor
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 10
        
        
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = CGPoint(x: progressView.bounds.width / 2, y: progressView.bounds.height / 2)
        
        progressView.addSubview(activityIndicator)
        containerView.addSubview(progressView)
        view.addSubview(containerView)
        
        activityIndicator.startAnimating()
        
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
    }
    
}
