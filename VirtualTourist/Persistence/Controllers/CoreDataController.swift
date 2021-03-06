//
//  CoreDataController.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 17/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataContext {
    case view
    case background
}

class CoreDataController {
    
    // MARK: Singleton
    static let shared = CoreDataController(modelName: "VirtualTourist")
    
    // MARK: Properties
    let persistentContainer: NSPersistentContainer
    let backgroundContext:NSManagedObjectContext!
    
    // MARK: Computed Properties
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Initialization
    init(modelName: String!) {
        persistentContainer = NSPersistentContainer(name: modelName)
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
        
    }
    
    func saveViewContext() {
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error {
                debugPrint("error: \(error.localizedDescription)")
            }
        }
        
    }
    
}


