//
//  SnapcodeEndpointRequest.swift
//  Live-Snap
//
//  Created by Oleg Abalonski on 1/6/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import UIKit
import Alamofire

class SnapcodeEndpointRequest {
    
    var snapchatUsername: String
    
    init(snapchatUsername: String) {
        self.snapchatUsername = snapchatUsername
    }
    
    //https://github.com/Alamofire/AlamofireImage
    //Shouldn't we be Almofire.download the image???
    // Make a network call to api and return a snapcode image if successful
    func start(completion: @escaping ((UIImage?) -> ())) {
        
        let url = "https://feelinsonice-hrd.appspot.com/web/deeplink/snapcode?username=\(snapchatUsername)&type=PNG&size=800"
    
        // Make Alamofire request
        Alamofire.request(url).responseData { response in
            if let imageData = response.result.value {
                let image = UIImage(data: imageData)
                completion(image)
            }
        }

    
    }
    
}
