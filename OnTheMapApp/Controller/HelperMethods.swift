//
//  Alert.swift
//  OnTheMapApp
//
//  Created by Luciana Lordelo Nascimento on 10/10/2018.
//  Copyright © 2018 Luciana Lordelo Nascimento. All rights reserved.
//

import UIKit

class HelperMethods {
    
    class func alertController(title:String, message: String) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        controller.addAction(action)
        return controller
    }
    
    static func startActivityIndicator (_ view: UIView, activityIndicator: UIActivityIndicatorView) {
        activityIndicator.center = view.center
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        let centerX =  NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let centerY =  NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        view.addSubview(activityIndicator)
        view.addConstraints([centerX,centerY])
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    static func stopActivityIndicator (_ view: UIView, activityIndicator: UIActivityIndicatorView) {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
