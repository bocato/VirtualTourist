//
//  AlertHelper.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 04/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import UIKit

class AlertHelper: NSObject {
    
    static func showAlert(in controller: UIViewController, withTitle title: String?, message: String?, action: UIAlertAction? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action ?? defaultAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    static func showAlert(in controller: UIViewController, withTitle title: String?, message: String?, leftAction: UIAlertAction!, rightAction: UIAlertAction!) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(leftAction)
        alertController.addAction(rightAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
}
