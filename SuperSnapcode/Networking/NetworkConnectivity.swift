//
//  NetworkConnectivity.swift
//  SnapShare
//
//  Created by Oleg Abalonski on 6/10/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import Foundation
import Alamofire

class NetworkConnectivity {
    class var isConnected: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
