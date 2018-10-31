//
//  Alert.swift
//  OnTheMapApp
//
//  Created by Luciana Lordelo Nascimento on 10/10/2018.
//  Copyright © 2018 Luciana Lordelo Nascimento. All rights reserved.
//

import UIKit

class alert {
    
    func alertController(title:String, message: String) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        controller.addAction(action)
        return controller
    }
}
