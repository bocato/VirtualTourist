//
//  ErrorFactory.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 15/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation

class ErrorFactory {
    
    static func buildServiceError(with code: ErrorCode!) -> ServiceError! {
        switch code {
        case .unknown:
            return ServiceError(message: ErrorMessage.unknown.rawValue, code: ErrorCode.unknown.rawValue)
        case .unexpected:
            return ServiceError(message: ErrorMessage.unexpected.rawValue, code: ErrorCode.unexpected.rawValue)
        case .flickrError:
            return ServiceError(message: ErrorMessage.flickrError.rawValue, code: ErrorCode.flickrError.rawValue)
        default:
            return ServiceError(message: ErrorMessage.unknown.rawValue, code: ErrorCode.unknown.rawValue)
        }
    }
    
    static func buildPersistenceError(with code: ErrorCode!) -> PersistenceError! {
        switch code {
        case .couldNotFindPersistedObject:
            return PersistenceError(message: ErrorMessage.couldNotFindPersistedObject.rawValue, code: ErrorCode.couldNotFindPersistedObject.rawValue)
        case .couldNotPersistObject:
            return PersistenceError(message: ErrorMessage.couldNotPersistObject.rawValue, code: ErrorCode.couldNotPersistObject.rawValue)
        case .couldNotFetchDataFromPersistenceLayer:
            return PersistenceError(message: ErrorMessage.couldNotFetchDataFromPersistenceLayer.rawValue, code: ErrorCode.couldNotFetchDataFromPersistenceLayer.rawValue)
        case .objectAlreadyExistsOnLocalDatabase:
            return PersistenceError(message: ErrorMessage.objectAlreadyExistsOnLocalDatabase.rawValue, code: ErrorCode.objectAlreadyExistsOnLocalDatabase.rawValue)
        case .couldNotDeleteObject:
            return PersistenceError(message: ErrorMessage.couldNotDeleteObject.rawValue, code: ErrorCode.couldNotDeleteObject.rawValue)
        case .noObjectsToDelete:
            return PersistenceError(message: ErrorMessage.noObjectsToDelete.rawValue, code: ErrorCode.noObjectsToDelete.rawValue)
        default:
            return PersistenceError(message: ErrorMessage.unknown.rawValue, code: ErrorCode.unknown.rawValue)
        }
    }
    
}
