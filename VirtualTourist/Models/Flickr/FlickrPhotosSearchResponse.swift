//
//  PhotosSearchResponse.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 15/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation

struct FlickrPhotosSearchResponse: Codable {
    
    var photos: FlickrPhotos?
    var status: String?
    var code: Int?
    var message: String?

    enum CodingKeys: String, CodingKey {
        case photos, code, message
        case status = "stat"
    }
    
}
