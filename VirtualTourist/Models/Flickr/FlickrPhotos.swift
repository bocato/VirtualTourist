//
//  Photos.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 15/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation

struct FlickrPhotos: Codable {
    
    var page: Int?
    var pages: Int?
    var perPage: Int?
    var total: String?
    var photo: [FlickrPhoto]?
    
    enum CodingKeys: String, CodingKey {
        case page, pages, total, photo
        case perPage = "perpage"
    }
    
}
