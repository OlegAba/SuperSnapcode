//
//  ImageManager.swift
//  Live-Snap
//
//  Created by Oleg Abalonski on 1/24/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import Photos

class PhotoAlbum {
    var name: String
    var assets: PHFetchResult<PHAsset>
    
    init(name: String, assets: PHFetchResult<PHAsset>) {
        self.name = name
        self.assets = assets
    }
    
    func assetArray() -> [PHAsset] {
        var results = [PHAsset]()
        assets.enumerateObjects { (asset: PHAsset, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            results.append(asset)
        }
        return results
    }
}

class ImageManager {
    
    static let shared = ImageManager()
    
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> ()) {
        PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
            completion(!(status == .denied || status == .restricted))
        }
    }
    
    func photoLibraryPermissionWasDenied() {
     
        let deniedPermissionViewControllerIsActive: Bool = System.shared.appDelegate().pageViewController?.viewControllers![0] is DeniedPhotoLibraryPermissionViewController
        
        if !deniedPermissionViewControllerIsActive {
            let deniedPhotoLibraryPermissionViewController = DeniedPhotoLibraryPermissionViewController()
            System.shared.appDelegate().pageViewController?.setViewControllers([deniedPhotoLibraryPermissionViewController], direction: .reverse, animated: true, completion: nil)
        }
    }
    
    func grabAllPhotoAlbums() -> [PhotoAlbum] {
        
        var albumAssets = [String: PHFetchResult<PHAsset>]()
        var results = [PhotoAlbum]()
        
        //grabbing all photo assets
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchedAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if fetchedAssets.count > 0 {
            albumAssets["All Photos"] = fetchedAssets
        } else {
            print("No Photos in Library")
            return results
        }
        
        //grabbing user album assets
        let albumAssetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: PHFetchOptions())
        albumAssetCollections.enumerateObjects{ (assetCollection: PHAssetCollection, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if let albumName = assetCollection.localizedTitle {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                let fetchedAssets = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
                if fetchedAssets.count > 0 {
                    albumAssets[albumName] = fetchedAssets
                }
            }
        }
        
        
        //Grabing smart album assets
        let smartAlbumSubtypes: [PHAssetCollectionSubtype] = [.smartAlbumFavorites,
                                                              .smartAlbumRecentlyAdded,
                                                              .smartAlbumSelfPortraits,
                                                              .smartAlbumScreenshots,
                                                              .smartAlbumDepthEffect,
                                                              .smartAlbumLivePhotos]
        
        
        for albumSubtype in smartAlbumSubtypes {
            let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: albumSubtype, options: PHFetchOptions())
            smartAlbum.enumerateObjects{ (assetCollection: PHAssetCollection, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                if let albumName = assetCollection.localizedTitle {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    let fetchedAssets = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
                    if fetchedAssets.count > 0 {
                        albumAssets[albumName] = fetchedAssets
                    }
                }
            }
        }
        
        for (albumName, assets) in albumAssets {
            results.append(PhotoAlbum(name: albumName, assets: assets))
        }
        
        if results[0].name != "All Photos" {
            for index in 1..<results.count {
                if results[index].name == "All Photos" {
                    results.swapAt(0, index)
                    break
                }
            }
        }
        
        return results
    }
    
    func findPhotoAlbum(photoAlbums: [PhotoAlbum], name: String) -> PhotoAlbum? {
        for album in photoAlbums {
            if album.name == name {
                return album
            }
        }
        return nil
    }
    
    func grabThumnailFrom(photoAlbum: PhotoAlbum, index: Int, completion: @escaping (UIImage?) -> ()) {
        
        let imageManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        let imageSize = CGSize(width: 250, height: 250)
        
        imageManager.requestImage(for: photoAlbum.assets.object(at: index), targetSize: imageSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image: UIImage?, info: [AnyHashable : Any]?) in
            guard let thumbnail = image else { completion(nil); return }
            completion(thumbnail)
        })
    }
    
    func grabFullPhotoFromAsset(asset: PHAsset, completion: @escaping (UIImage?) -> ()) {
        
        let imageManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image: UIImage?, info: [AnyHashable : Any]?) in
            
            completion(image)
        })
    }
    
}
