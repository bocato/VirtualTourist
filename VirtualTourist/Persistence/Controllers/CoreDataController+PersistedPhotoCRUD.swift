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
    func addPersistedPhoto(for flickrPhoto: FlickrPhoto!, mapPin: MapPin!, context: CoreDataContext = .background, success: @escaping ((_ persistedPhoto: PersistedPhoto) -> Void), onFailure failure: ((PersistenceError?) -> Void)? = nil, onCompletion completion: (() -> Void)? = nil){
        
        guard let id = flickrPhoto.id else {
            failure?(ErrorFactory.buildPersistenceError(with: .couldNotPersistObject))
            return
        }
        
        let currentContext: NSManagedObjectContext = context == .background ? backgroundContext : viewContext
        
        if getPersistedPhoto(with: id, context: context) == nil { // no Photos with this ID yet, save new PersistedPhoto
            
            let persistedPhoto = PersistedPhoto(context: backgroundContext)
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
            
        } else {
            debugPrint("We already have a PersistedPhoto with id = \(id)")
            failure?(ErrorFactory.buildPersistenceError(with: .objectAlreadyExistsOnLocalDatabase))
        }
        
        completion?()
        
    }
    
    func deletePersistedPhoto(with id: String!, context: CoreDataContext = .background, success: @escaping (() -> Void), onFailure failure: ((PersistenceError?) -> Void)? = nil, onCompletion completion: (() -> Void)? = nil) {
        
        guard let persistedPhoto = getPersistedPhoto(with: id, context: context) else {
            debugPrint("Could not find PersistedPhoto with id = \(id)")
            failure?(ErrorFactory.buildPersistenceError(with: .couldNotFindPersistedObject))
            return
        }
        
        let currentContext: NSManagedObjectContext = context == .background ? backgroundContext : viewContext
        
        currentContext.delete(persistedPhoto)
        do {
            try currentContext.save()
            debugPrint("Sucessfully deleted PersistedPhoto with id = \(id)")
            success()
        } catch let error {
            debugPrint("backgroundContext.save did fail with error: \n\(error)")
            failure?(ErrorFactory.buildPersistenceError(with: .couldNotDeleteObject))
        }
        
        completion?()
        
    }
    
    func getPersistedPhoto(with id: String!, context: CoreDataContext = .background) -> PersistedPhoto? {
        
        let currentContext: NSManagedObjectContext = context == .background ? backgroundContext : viewContext
        
        let fetchRequest = NSFetchRequest<PersistedPhoto>(entityName: "PersistedPhoto")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let result = try currentContext.fetch(fetchRequest)
            guard let persistedPhoto = result.first else {
                debugPrint("Did not found any PersistedPhoto with id = \(id)")
                return nil
            }
            return persistedPhoto
        } catch let error {
            debugPrint("getPersistedPhoto(with id: \(id) failed with error:\n\(error)")
            return nil
        }
    }
    
}
