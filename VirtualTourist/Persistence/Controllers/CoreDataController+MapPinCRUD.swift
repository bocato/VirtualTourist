//
//  CoreDataController+MapPinCRUD.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 18/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

extension CoreDataController {
    
    // MARK: - Helpers
    func getPinId(for coordinate: CLLocationCoordinate2D!) -> String {
        return "\(coordinate.latitude)&\(coordinate.longitude)"
    }
    
    // MARK: - Pin CRUD
    func addMapPin(for coordinate: CLLocationCoordinate2D!, context: CoreDataContext = .background, success: @escaping ((_ mapPin: MapPin) -> Void), onFailure failure: ((PersistenceError?) -> Void)? = nil, onCompletion completion: (() -> Void)? = nil){
        
        let id = getPinId(for: coordinate)
        
        let currentContext: NSManagedObjectContext = context == .background ? backgroundContext : viewContext
        
        currentContext.perform {
            
            let pin = MapPin(context: currentContext)
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude
            pin.id = id
            
            do {
                try currentContext.save()
                debugPrint("sucessfully saved pin with id = \(id)")
                success(pin)
            } catch let error {
                debugPrint("backgroundContext.save did fail with error: \n\(error)")
                failure?(ErrorFactory.buildPersistenceError(with: .couldNotPersistObject))
            }
            
            completion?()
            
        }
        
    }
    
    func deletePin(for coordinate: CLLocationCoordinate2D!, context: CoreDataContext = .background, success: @escaping (() -> Void), onFailure failure: ((PersistenceError?) -> Void)? = nil, onCompletion completion: (() -> Void)? = nil) {
        
        let id = getPinId(for: coordinate)
        
        let currentContext: NSManagedObjectContext = context == .background ? backgroundContext : viewContext
        
        currentContext.perform {
            
            self.getMapPin(with: id, context: context, success: { (pin) in
                
                guard let pin = pin else {
                    debugPrint("Could not find pin with id = \(id)")
                    failure?(ErrorFactory.buildPersistenceError(with: .couldNotFindPersistedObject))
                    return
                }
                
                currentContext.delete(pin)
                do {
                    try currentContext.save()
                    debugPrint("sucessfully deleted pin with id = \(id)")
                    success()
                } catch let error {
                    debugPrint("backgroundContext.save did fail with error: \n\(error)")
                    failure?(ErrorFactory.buildPersistenceError(with: .couldNotDeleteObject))
                }
                
            }, onFailure: failure, onCompletion: completion)
            
        }
        
        
    }
    
    func findAllPins(in context: CoreDataContext = .background, success: @escaping ((_ pins: [MapPin]?) -> Void), onFailure failure: ((PersistenceError?) -> Void)? = nil, onCompletion completion: (() -> Void)? = nil) {
        
        let currentContext: NSManagedObjectContext = context == .background ? backgroundContext : viewContext
        
        currentContext.perform {
            
            let fetchRequest = NSFetchRequest<MapPin>(entityName: "MapPin")
            
            do {
                let result = try currentContext.fetch(fetchRequest)
                success(result)
            } catch let error {
                debugPrint("findAllPins() failed with error:\n\(error)")
                failure?(ErrorFactory.buildPersistenceError(with: .couldNotFetchDataFromPersistenceLayer))
            }
            completion?()
            
        }
        
    }
    
    func getMapPin(with id: String!, context: CoreDataContext = .view, success: @escaping ((_ pin: MapPin?) -> Void), onFailure failure: ((PersistenceError?) -> Void)? = nil, onCompletion completion: (() -> Void)? = nil) {
        
        let currentContext: NSManagedObjectContext = context == .background ? backgroundContext : viewContext
        
        currentContext.perform {
            
            let fetchRequest = NSFetchRequest<MapPin>(entityName: "MapPin")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            fetchRequest.fetchLimit = 1
            
            do {
                let result = try currentContext.fetch(fetchRequest)
                guard let mapPin = result.first else {
                    debugPrint("Did not found any MapPin with id = \(id)")
                    failure?(ErrorFactory.buildPersistenceError(with: .couldNotFindPersistedObject))
                    return
                }
                success(mapPin)
            } catch let error {
                debugPrint("getMapPin(with id: \(id)) failed with error:\n\(error)")
                failure?(ErrorFactory.buildPersistenceError(with: .couldNotFindPersistedObject))
            }
            
            completion?()
        }
        
    }
    
}
