//
//  Environment.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 15/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation

class Environment {
    
    // MARK: Enums
    enum EnvironmentType: String {
        case dev = "dev"
    }
    
    // MARK: - Singleton
    static let shared = Environment()
    
    // MARK: - Properties
    var flickrBaseURL: String!
    var flickrRestApiKey: String!
    
    var runtimeEnvironment: EnvironmentType! = .dev
    
    // MARK: - Computed Properties
    var currentRuntimeEnvironment: EnvironmentType? {
        guard let runtimeEnvironment = runtimeEnvironment else {
            return .dev
        }
        return runtimeEnvironment
    }
    
    // MARK: - Lifecycle
    private init() {
        setup()
    }
    
    // MARK: - Configuration
    private func setup() {
        guard let runtimeEnvironment = currentRuntimeEnvironment else { return }
        switch runtimeEnvironment {
        case .dev:
            self.flickrBaseURL = "https://api.flickr.com/services/rest"
            self.flickrRestApiKey = "c8c502c21c8243f8d3d56f0edde38b55"
            break
        }
    }
    
}
