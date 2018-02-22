//
//  StringExtension.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 15/02/18.
//  Copyright © 2017 Eduardo Sanches Bocato. All rights reserved.
//

import UIKit

public extension String {
    
    var isValidURL: Bool {
        guard let url = NSURL(string: self) else {
            return false
        }
        if !UIApplication.shared.canOpenURL(url as URL) {
            return false
        }
        let regularExpression = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regularExpression])
        return predicate.evaluate(with: self)
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return boundingBox.height
    }
    
}
