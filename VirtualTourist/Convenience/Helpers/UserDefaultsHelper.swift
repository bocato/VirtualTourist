//
//  UserDefaultsHelper.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 17/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation
import MapKit

private enum MKCoordinateRegionKey: String {
    case centerLatitude = "MKCoordinateRegionCenterLatitude"
    case centerLongitude = "MKCoordinateRegionCenterLongitude"
    case spanLatitudeDelta = "MKCoordinateRegionSpanLatitudeDelta"
    case spanLongitudeDelta = "MKCoordinateRegionSpanLongitudeDelta"
}
class UserDefaultsHelper {
    
    static func persistMapRegion(_ region: MKCoordinateRegion) {
        UserDefaults.standard.setValue(Double(region.center.latitude), forKey: MKCoordinateRegionKey.centerLatitude.rawValue)
        UserDefaults.standard.setValue(Double(region.center.longitude), forKey: MKCoordinateRegionKey.centerLongitude.rawValue)
        UserDefaults.standard.setValue(Double(region.span.latitudeDelta), forKey: MKCoordinateRegionKey.spanLatitudeDelta.rawValue)
        UserDefaults.standard.setValue(Double(region.span.longitudeDelta), forKey: MKCoordinateRegionKey.spanLongitudeDelta.rawValue)
    }
    
    static func getMapRegion() -> MKCoordinateRegion? {
        guard let centerLatitude = UserDefaults.standard.value(forKey: MKCoordinateRegionKey.centerLatitude.rawValue) as? CLLocationDegrees,
            let centerLongitude = UserDefaults.standard.value(forKey: MKCoordinateRegionKey.centerLongitude.rawValue) as? CLLocationDegrees,
            let spanLatitudeDelta = UserDefaults.standard.value(forKey: MKCoordinateRegionKey.spanLatitudeDelta.rawValue) as? CLLocationDegrees,
            let spanLongitudeDelta = UserDefaults.standard.value(forKey: MKCoordinateRegionKey.spanLongitudeDelta.rawValue) as? CLLocationDegrees else {
            return nil
        }
        return MKCoordinateRegionMake(CLLocationCoordinate2DMake(centerLatitude, centerLongitude), MKCoordinateSpanMake(spanLatitudeDelta, spanLongitudeDelta))
    }
    
}
