//
//  LivePhoto.swift
//  Live-Snap
//
//  Created by Baby on 1/18/18.
//  Copyright © 2018 Baby. All rights reserved.
//

import Photos

class LivePhoto {
    
    var phLivePhoto: PHLivePhoto
    var imageURL: URL
    var videoURL: URL
    
    init(phLivePhoto: PHLivePhoto, imageURL: URL, videoURL: URL) {
        self.phLivePhoto = phLivePhoto
        self.imageURL = imageURL
        self.videoURL = videoURL
    }
    
    func writeToPhotoLibrary(completion: @escaping (Bool) -> ()) {
        PHPhotoLibrary.shared().performChanges({
            
            let request = PHAssetCreationRequest.forAsset()
            
            request.addResource(with: .photo, fileURL: self.imageURL, options: nil)
            request.addResource(with: .pairedVideo, fileURL: self.videoURL, options: nil)
            
        }) { (success: Bool, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
            completion(success)
        }
    }
}
