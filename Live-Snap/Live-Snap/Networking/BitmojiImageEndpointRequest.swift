//
//  BitmojiImageEndpointRequest.swift
//  Live-Snap
//
//  Created by Baby on 3/13/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import UIKit
import Alamofire

class BitmojiImageEndpointRequest {
    
    var snapchatUsername: String
    
    init(snapchatUsername: String) {
        self.snapchatUsername = snapchatUsername
    }
    
    func start(completion: @escaping ((UIImage?) -> ())) {
        
        let url = "https://feelinsonice-hrd.appspot.com/web/deeplink/snapcode?username=\(snapchatUsername)&type=SVG"
        
        Alamofire.request(url).validate().responseString { (response: DataResponse<String>) in
            
            
            switch response.result {
            case .success:
                
                if let responseString = response.result.value {
                   
                    if let base64EndodedPNGString = responseString.stringBetweenSubstrings(beginSubstring: "data:image/png;base64,", endSubstring: "\""),
                    let imageData = Data(base64Encoded: base64EndodedPNGString) {
                        completion(UIImage(data: imageData))
                        return
                    }
                    completion(nil)
                } else {
                    completion(nil)
                }
            case .failure(let error):
                completion(nil)
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

