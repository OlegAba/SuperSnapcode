//
//  BitmojiSnapcodeEndpointRequest.swift
//  Live-Snap
//
//  Created by Baby on 3/4/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import UIKit
import Alamofire
import SVGKit

class BitmojiSnapcodeEndpointRequest {
    
    var snapchatUsername: String
    
    init(snapchatUsername: String) {
        self.snapchatUsername = snapchatUsername
    }
    
    func start(completion: @escaping ((UIImage?) -> ())) {
        
        let url = "https://feelinsonice-hrd.appspot.com/web/deeplink/snapcode?username=\(snapchatUsername)&type=SVG"
        
        Alamofire.request(url).validate().responseData { (response: DataResponse<Data>) in
            
            
            switch response.result {
            case .success:
                
                if let imageData = response.result.value {
                    let svgImage = SVGKImage(data: imageData)
                    let image = svgImage?.uiImage
                    completion(image)
                } else {
                    completion(nil)
                }
            case .failure(let error):
                let statusCode = response.response?.statusCode
                let errorMessage = error.localizedDescription
                
                print("\n---Request Failed---")
                print("URL: \(url)")
                print("Status Code: \(String(describing: statusCode))")
                print("Error Message: \(errorMessage)")
            }
            
        }
    }
}
