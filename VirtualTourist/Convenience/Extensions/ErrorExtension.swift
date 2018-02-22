//
//  ErrorExtension.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 15/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation

extension Error {
    
    var networkErrors: [Int] {
        return [NSURLErrorCannotConnectToHost, NSURLErrorNetworkConnectionLost, NSURLErrorDNSLookupFailed, NSURLErrorResourceUnavailable,
                NSURLErrorNotConnectedToInternet, NSURLErrorBadServerResponse, NSURLErrorInternationalRoamingOff, NSURLErrorCallIsActive]
    }
    
    var isNetworkConnectionError: Bool {
        if (self as NSError).domain == NSURLErrorDomain && networkErrors.contains((self as NSError).code) {
            return true
        }
        return false
    }
    
}
