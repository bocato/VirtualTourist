//
//  FlickrService.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 15/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation

class FlickrService {
    
    func findPhotos(atLatitude latitude: Double? = nil, longitude: Double? = nil, page: Int = 1, success: @escaping ((_ photosSearchResponse: FlickrPhotosSearchResponse?) -> Void), onFailure failure: ((ServiceError?) -> Void)? = nil, onCompletion completion: (() -> Void)? = nil) {
        
        let urlString = createSearchMethodURL(with: latitude, longitude: longitude, page: page)
        let url = URL(string: urlString)!
        
        Service.shared.request(httpMethod: .get, url: url).response(success: { (photosSearchResponse: FlickrPhotosSearchResponse?, serviceResponse: ServiceResponse?) in
            guard let status = photosSearchResponse?.status, status == FlickrConstants.ResponseValues.okStatus else {
                guard let code = photosSearchResponse?.code, let message = photosSearchResponse?.message else {
                    failure?(ErrorFactory.buildServiceError(with: .flickrError))
                    return
                }
                failure?(ServiceError(message: message, code: code))
                return
            }
            success(photosSearchResponse)
        }, failed: { errorResponse in
            failure?(errorResponse.serviceError)
        }, completed: {
            completion?()
        })
        
    }
    
    func downloadPhoto(fromURL url: String!, success: @escaping ((_ imageData: Data?) -> Void), onFailure failure: ((ServiceError?) -> Void)? = nil, onCompletion completion: (() -> Void)? = nil) -> URLSessionDataTask {
        
        let task = Service.shared.request(httpMethod: .get, url: URL(string: url)!).response(success: { (_ serviceResponse: ServiceResponse?) in
            success(serviceResponse?.data)
        },  failed: { (errorResponse) in
            failure?(errorResponse.serviceError)
        }, completed: {
            completion?()
        })
        
        return task
    }
    
}

extension FlickrService {
    
    private func createSearchMethodURL(with latitude: Double? = nil, longitude: Double? = nil, page: Int = 1) -> String {
        
        func createBoundingBoxString(fromLatitude latitude: Double? = nil, longitude: Double? = nil) -> String {
            // ensure bbox is bounded by minimum and maximums
            if let latitude = latitude, let longitude = longitude {
                let minimumLongitude = max(longitude - FlickrConstants.searchBBoxHalfWidth, FlickrConstants.searchLonRange.0)
                let minimumLatitude = max(latitude - FlickrConstants.searchBBoxHalfHeight, FlickrConstants.searchLatRange.0)
                let maximumLongitude = min(longitude + FlickrConstants.searchBBoxHalfWidth, FlickrConstants.searchLonRange.1)
                let maximumLatitude = min(latitude + FlickrConstants.searchBBoxHalfHeight, FlickrConstants.searchLatRange.1)
                return "\(minimumLongitude),\(minimumLatitude),\(maximumLongitude),\(maximumLatitude)"
            } else {
                return "0,0,0,0"
            }
        }
        
        let methodParameters: [String: String] = [
            FlickrConstants.ParameterKeys.method: FlickrConstants.ParameterValues.searchMethod,
            FlickrConstants.ParameterKeys.apiKey: Environment.shared.flickrRestApiKey,
            FlickrConstants.ParameterKeys.boundingBox: createBoundingBoxString(fromLatitude: latitude, longitude: longitude),
            FlickrConstants.ParameterKeys.safeSearch: FlickrConstants.ParameterValues.useSafeSearch,
            FlickrConstants.ParameterKeys.extras: FlickrConstants.ParameterValues.mediumURL,
            FlickrConstants.ParameterKeys.format: FlickrConstants.ParameterValues.responseFormat,
            FlickrConstants.ParameterKeys.noJSONCallback: FlickrConstants.ParameterValues.disableJSONCallback,
            FlickrConstants.ParameterKeys.perPage: FlickrConstants.ParameterValues.perPage,
            FlickrConstants.ParameterKeys.page: "\(page)"
        ]
        
        return Environment.shared.flickrBaseURL + URLHelper.escapedParameters(methodParameters)
    
    }
    
    
}
