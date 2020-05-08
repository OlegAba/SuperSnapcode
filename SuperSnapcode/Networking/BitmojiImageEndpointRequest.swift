import UIKit
import Alamofire

class BitmojiImageEndpointRequest {
    
    var snapchatUsername: String
    
    init(snapchatUsername: String) {
        self.snapchatUsername = snapchatUsername
    }
    
    func start(completion: @escaping ((UIImage?) -> ())) {
        
        let url = "https://feelinsonice-hrd.appspot.com/web/deeplink/snapcode?username=\(snapchatUsername)&type=SVG"
        
        AF.request(url).validate().responseString { (response: AFDataResponse<String>) in
            
            switch response.result {
            case .success:
                
                if let responseString = response.value {
                   
                    if let base64EndodedPNGString = responseString.stringBetweenSubstrings(beginSubstring: "data:image/png;base64,", endSubstring: "\""),
                    let imageData = Data(base64Encoded: base64EndodedPNGString) {
                        completion(UIImage(data: imageData))
                        return
                    } else {
                        completion(nil)
                    }
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
                
                completion(nil)
            }
        }
    }
}

