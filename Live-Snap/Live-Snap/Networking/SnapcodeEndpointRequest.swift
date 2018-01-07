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
    
    func start(completion: @escaping ((UIImage?) -> ())) {
        
        let url = "https://feelinsonice-hrd.appspot.com/web/deeplink/snapcode?username=\(snapchatUsername)&type=PNG&size=800"
    
        Alamofire.request(url).responseData { (response: DataResponse<Data>) in

            response.result.ifSuccess {
                if let imageData = response.result.value {
                    let image = UIImage(data: imageData)
                    completion(image)
            }
            }
            
            response.result.ifFailure {
                print("Error in making the request")
            }
                
        
        }
    }
}
