//
//  ErrorEnums.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 10/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation

enum ErrorCode: Int {
    case unknown = -111
    case unexpected = -222
    case flickrError = -333
    case couldNotFindPersistedObject = -444
    case couldNotPersistObject = -555
    case couldNotFetchDataFromPersistenceLayer = -666
    case objectAlreadyExistsOnLocalDatabase = -777
    case couldNotDeleteObject = -888
    case noObjectsToDelete = -999
}

enum ErrorMessage: String {
    case unknown = "An unknown error has occured. Try again later."
    case unexpected = "An unexpected error has occured. Check your internet connection and try again."
    case flickrError = "An unknown Flicker API error has occured. Try again later."
    case couldNotFindPersistedObject = "Could not find object."
    case couldNotPersistObject = "Could not persist object.  Try again later."
    case couldNotFetchDataFromPersistenceLayer = "Could not fetch data from local database."
    case objectAlreadyExistsOnLocalDatabase = "Object already exists on local database."
    case couldNotDeleteObject = "Could not delete object from local database.  Try again later."
    case noObjectsToDelete = "There are no objects to delete."
}

enum ErrorDomain: String {
    case persistenceLayer = "PersistenceLayer"
}
