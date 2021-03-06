//
//  PersistenceError.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 18/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation

struct PersistenceError: Error {
    
    // MARK: - Properties
    var message: String?
    var code: Int?
    let domain: ErrorDomain = ErrorDomain.persistenceLayer
    
}
