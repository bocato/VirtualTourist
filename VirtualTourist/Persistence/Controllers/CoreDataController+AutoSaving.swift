//
//  CoreDataController+AutoSaving.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 18/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import Foundation

// MARK: - Autosaving
extension CoreDataController {
    
    func autoSaveViewContext(interval:TimeInterval = 30) {
        
        debugPrint("Auto saving ViewContext...")
        
        guard interval > 0 else { return }
        
        saveViewContext()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
        
    }
    
}
