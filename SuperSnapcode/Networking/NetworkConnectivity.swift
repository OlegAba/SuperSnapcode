import Foundation
import Alamofire

class NetworkConnectivity {
    class var isConnected: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
