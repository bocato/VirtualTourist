//
//  CLLocationCoordinate2DExtensions.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 21/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
}
