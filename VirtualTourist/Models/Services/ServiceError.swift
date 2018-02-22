//
//  ServiceError.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 15/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation

struct ServiceError: Codable, Error {
    
    // MARK: - Properties
    var message: String?
    var code: Int?
    
}
