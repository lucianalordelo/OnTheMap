//
//  URLHelper.swift
//  OnTheMapApp
//
//  Created by Luciana Lordelo Nascimento on 05/10/2018.
//  Copyright © 2018 Luciana Lordelo Nascimento. All rights reserved.
//

import Foundation

struct ApiHelper {
    
    struct Base {
        
        static let udacity = "https://www.udacity.com/api/"
        static let parse = "https://parse.udacity.com/parse/classes/"
        
    }
    
    struct Constants {
        
        static let parseAppId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let parseApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
    }
    
    struct Extras {
        
        static let studentLocation = "StudentLocation"
        static let session = "session"
        static let users = "users"
        
    }
    
    struct UdacityResponses {
        
        static let users = "users"
        
    }
}
