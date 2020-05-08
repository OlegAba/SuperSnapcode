import UIKit
import Alamofire

class SnapcodeEndpointRequest {
    
    var snapchatUsername: String

    init(snapchatUsername: String) {
        self.snapchatUsername = snapchatUsername
    }

    func start(completion: @escaping ((UIImage?) -> ())) {
        
        let url = "https://feelinsonice-hrd.appspot.com/web/deeplink/snapcode?username=\(snapchatUsername)&type=PNG&size=800"

        AF.request(url).validate().responseData { (response: AFDataResponse<Data>) in
            
            switch response.result {
            case .success:
                if let imageData = response.data {
                    let image = UIImage(data: imageData)
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
                
                completion(nil)
            }
        }
    }
}
