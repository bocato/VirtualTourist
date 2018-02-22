//
//  PersistendPhotoExtensions.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 18/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation
import CoreData

extension PersistedPhoto {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
    func imageURL(forSize size: FlickrPhotoSize = .thumbnail) -> String? {
        guard let server = server, let id = id, let secret = secret else {
            return nil
        }
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(size.rawValue).jpg"
    }
    
}
