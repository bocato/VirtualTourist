//
//  FlickrPhoto.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 15/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation

struct FlickrPhoto: Codable {
    
    var id: String?
    var owner: String?
    var secret: String?
    var server: String?
    var farm: Int?
    var title: String?
    var isPublic: Int?
    var isFriend: Int?
    var isFamily: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, owner, secret, server, farm, title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
    
}

extension FlickrPhoto {
    
    func imageURL(forSize size: FlickrPhotoSize = .thumbnail) -> String? {
        guard let farm = farm, let server = server, let id = id, let secret = secret else {
            return nil
        }
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(size.rawValue).jpg"
    }
    
}
