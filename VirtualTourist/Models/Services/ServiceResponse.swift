//
//  ServiceResponse.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 15/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation

struct ServiceResponse {
    
    // MARK: - Properties
    var data: Data?
    
    var rawResponse: String?
    var response: HTTPURLResponse?
    var request: URLRequest?
    
    var serviceError: ServiceError?
    
}
