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

        Alamofire.request(url).validate().responseData { (response: DataResponse<Data>) in
            
            switch response.result {
            case .success:
                if let imageData = response.result.value {
                    let image = UIImage(data: imageData)
                    completion(image)
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
