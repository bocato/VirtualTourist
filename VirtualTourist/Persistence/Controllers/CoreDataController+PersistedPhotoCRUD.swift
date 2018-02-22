//
//  CoreDataController+PersistedPhotoCRUD.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 18/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation
import CoreData

extension CoreDataController {
    
    // MARK: - PersistedPhoto CRUD
    private func createPersistedPhoto(from flickrPhoto: FlickrPhoto!, for mapPin: MapPin!, in context: NSManagedObjectContext!) -> PersistedPhoto {
        let persistedPhoto = PersistedPhoto(context: context)
        persistedPhoto.id = flickrPhoto.id
        persistedPhoto.owner = flickrPhoto.owner
        persistedPhoto.secret = flickrPhoto.secret
        persistedPhoto.server = flickrPhoto.server
        persistedPhoto.farm = NSNumber(value: flickrPhoto.farm ?? 0).int32Value
        persistedPhoto.title = flickrPhoto.title
        persistedPhoto.title = flickrPhoto.title
        persistedPhoto.isPublic = flickrPhoto.isPublic == 1
        persistedPhoto.isFriend = flickrPhoto.isFriend == 1
        persistedPhoto.isFamily = flickrPhoto.isFamily == 1
        persistedPhoto.mapPin = mapPin
        return persistedPhoto
    }
    
    func persistFlickrPhotos(_ flickrPhotos: [FlickrPhoto]!, mapPin: MapPin!, context: CoreDataContext = .background, success: @escaping ((_ persistedPhotos: [PersistedPhoto]) -> Void), onFailure failure: ((PersistenceError?) -> Void)? = nil, onCompletion completion: (() -> Void)? = nil) {
        
        let currentContext: NSManagedObjectContext = context == .background ? backgroundContext : viewContext
        
        currentContext.perform {
            
            var persistedPhotos = [PersistedPhoto]()
            for flickrPhoto in flickrPhotos {
                let persistedPhoto = self.createPersistedPhoto(from: flickrPhoto, for: mapPin, in: currentContext)
                persistedPhotos.append(persistedPhoto)
            }
            
            do {
                try currentContext.save()
                debugPrint("Sucessfully saved PersistedPhotos.")
                success(persistedPhotos)
            } catch let error {
                debugPrint("backgroundContext.save did fail with error: \n\(error)")
                failure?(ErrorFactory.buildPersistenceError(with: .couldNotPersistObject))
            }
            
            completion?()
            
        }
        
    }
    
    func addPersistedPhoto(for flickrPhoto: FlickrPhoto!, mapPin: MapPin!, context: CoreDataContext = .background, success: @escaping ((_ persistedPhoto: PersistedPhoto) -> Void), onFailure failure: ((PersistenceError?) -> Void)? = nil, onCompletion completion: (() -> Void)? = nil){
        
        guard let id = flickrPhoto.id else {
            failure?(ErrorFactory.buildPersistenceError(with: .couldNotPersistObject))
            return
        }
        
        let currentContext: NSManagedObjectContext = context == .background ? backgroundContext : viewContext
        
        currentContext.perform {
            
            let persistedPhoto = PersistedPhoto(context: currentContext)
            persistedPhoto.id = flickrPhoto.id
            persistedPhoto.owner = flickrPhoto.owner
            persistedPhoto.secret = flickrPhoto.secret
            persistedPhoto.server = flickrPhoto.server
            persistedPhoto.farm = NSNumber(value: flickrPhoto.farm ?? 0).int32Value
            persistedPhoto.title = flickrPhoto.title
            persistedPhoto.title = flickrPhoto.title
            persistedPhoto.isPublic = flickrPhoto.isPublic == 1
            persistedPhoto.isFriend = flickrPhoto.isFriend == 1
            persistedPhoto.isFamily = flickrPhoto.isFamily == 1
            persistedPhoto.mapPin = mapPin
            
            do {
                try currentContext.save()
                debugPrint("Sucessfully saved PersistedPhoto with id = \(id)")
                success(persistedPhoto)
            } catch let error {
                debugPrint("backgroundContext.save did fail with error: \n\(error)")
                failure?(ErrorFactory.buildPersistenceError(with: .couldNotPersistObject))
            }
            
            completion?()
            
        }
        
    }
    
    func deletePersistedPhoto(with id: String!, context: CoreDataContext = .background, success: @escaping (() -> Void), onFailure failure: ((PersistenceError?) -> Void)? = nil, onCompletion completion: (() -> Void)? = nil) {
        
        let currentContext: NSManagedObjectContext = context == .background ? backgroundContext : viewContext
        
        currentContext.perform {
            
            self.getPersistedPhoto(with: id, context: context, success: { (photo) in
                
                guard let photo = photo else {
                    debugPrint("Could not find PersistedPhoto with id = \(id)")
                    failure?(ErrorFactory.buildPersistenceError(with: .couldNotFindPersistedObject))
                    return
                }
                
                currentContext.delete(photo)
                do {
                    try currentContext.save()
                    debugPrint("Sucessfully deleted PersistedPhoto with id = \(id)")
                    success()
                } catch let error {
                    debugPrint("currentContext.save() did fail with error: \n\(error)")
                    failure?(ErrorFactory.buildPersistenceError(with: .couldNotDeleteObject))
                }
                
            }, onFailure: failure, onCompletion: completion)
            
        }
        
    }
    
    func deletePersistedPhotos(_ persistedPhotos: [PersistedPhoto]!, mapPin: MapPin!, context: CoreDataContext = .background, success: @escaping (() -> Void), onFailure failure: ((PersistenceError?) -> Void)? = nil, onCompletion completion: (() -> Void)? = nil) {
        
        let currentContext: NSManagedObjectContext = context == .background ? backgroundContext : viewContext
        
        currentContext.perform {
            
            for persistedPhoto in persistedPhotos {
                currentContext.delete(persistedPhoto)
            }
            
            do {
                try currentContext.save()
                debugPrint("Sucessfully deleted PersistedPhotos.")
                success()
            } catch let error {
                debugPrint("currentContext.save() did fail with error: \n\(error)")
                failure?(ErrorFactory.buildPersistenceError(with: .couldNotPersistObject))
            }
            
            completion?()
            
        }
        
    }
    
    func getPersistedPhoto(with id: String!, context: CoreDataContext = .view, success: @escaping ((_ photo: PersistedPhoto?) -> Void), onFailure failure: ((PersistenceError?) -> Void)? = nil, onCompletion completion: (() -> Void)? = nil) {
        
        let currentContext: NSManagedObjectContext = context == .background ? backgroundContext : viewContext
        
        currentContext.perform {
            
            let fetchRequest = NSFetchRequest<PersistedPhoto>(entityName: "PersistedPhoto")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            do {
                let result = try currentContext.fetch(fetchRequest)
                guard let persistedPhoto = result.first else {
                    debugPrint("Did not found any PersistedPhoto with id = \(id)")
                    failure?(ErrorFactory.buildPersistenceError(with: .couldNotFindPersistedObject))
                    return
                }
                success(persistedPhoto)
            } catch let error {
                debugPrint("getPersistedPhoto(with id: \(id) failed with error:\n\(error)")
                failure?(ErrorFactory.buildPersistenceError(with: .couldNotFindPersistedObject))
            }
            
            completion?()
            
        }
        
    }
    
    func updatePersistedPhotoData(_ objectID: NSManagedObjectID!, data: Data!, context: CoreDataContext = .background, success: @escaping (() -> Void), onFailure failure: ((PersistenceError?) -> Void)? = nil, onCompletion completion: (() -> Void)? = nil){
        
        let currentContext: NSManagedObjectContext = context == .background ? backgroundContext : viewContext
        
        let persistedPhoto = currentContext.object(with: objectID) as! PersistedPhoto
        
        currentContext.perform {
            
            persistedPhoto.data = data
            
            do {
                try currentContext.save()
                debugPrint("Sucessfully updated PersistedPhoto with id = \(objectID)")
                success()
            } catch let error {
                debugPrint("backgroundContext.save did fail with error: \n\(error)")
                failure?(ErrorFactory.buildPersistenceError(with: .couldNotPersistObject))
            }
            
            completion?()
            
        }
        
    }
    
}
