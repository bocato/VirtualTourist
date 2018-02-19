//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 15/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation

struct FlickrConstants {
    
    // MARK: Flickr
    static let searchBBoxHalfWidth = 1.0
    static let searchBBoxHalfHeight = 1.0
    static let searchLatRange = (-90.0, 90.0)
    static let searchLonRange = (-180.0, 180.0)
    
    // MARK: Flickr Parameter Keys
    struct ParameterKeys {
        static let method = "method"
        static let apiKey = "api_key"
        static let galleryID = "gallery_id"
        static let extras = "extras"
        static let format = "format"
        static let noJSONCallback = "nojsoncallback"
        static let safeSearch = "safe_search"
        static let text = "text"
        static let boundingBox = "bbox"
        static let page = "page"
        static let perPage = "per_page"
    }
    
    // MARK: Flickr Parameter Values
    struct ParameterValues {
        static let searchMethod = "flickr.photos.search"
        static let responseFormat = "json"
        static let disableJSONCallback = "1" /* 1 means "yes" */
        static let galleryPhotosMethod = "flickr.galleries.getPhotos"
        static let galleryID = "5704-72157622566655097"
        static let mediumURL = "url_m"
        static let useSafeSearch = "1"
        static let perPage = "15"
    }
    
    // MARK: Response Values
    struct ResponseValues {
        static let okStatus = "ok"
        static let failStatus = "fail"
    }
    
}
