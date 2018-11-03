//
//  ParseApiClient.swift
//  OnTheMapApp
//
//  Created by Luciana Lordelo Nascimento on 05/10/2018.
//  Copyright © 2018 Luciana Lordelo Nascimento. All rights reserved.
//

import Foundation
import UIKit

class ParseApiClient: Client {
    
    func getLocations(_ completionHandler:@escaping ( [StudentInformation]?, _ error: String?)-> Void)  {
        
        let url = ApiHelper.Base.parse + ApiHelper.Extras.studentLocation
        
        let parameters = [
            "order": "-updatedAt",
            "limit": 100,
            ] as [String : Any]
        
        let headers = [
            "X-Parse-Application-Id": ApiHelper.Constants.parseAppId,
            "X-Parse-REST-API-Key": ApiHelper.Constants.parseApiKey
        ]
        let client = "parse"
        
        get(url, parameters as [String : AnyObject], headers, client) { (data, error) in
            if let error = error {
                completionHandler(nil, error.localizedDescription)
            }
            
            guard let data = data else {
                completionHandler(nil, error?.localizedDescription)
                return
            }
            
            if let results = data["results"] as? [[String:AnyObject]] {
                var studentsArray = [StudentInformation]()
                for result in results as [[String:AnyObject]]{
                    if let _ = result["firstName"] as? String, let _ = result["lastName"] as? String, let _ = result["mediaURL"] {
                        studentsArray.append(StudentInformation(dictionary: result))
                    }
                }
                completionHandler(studentsArray,nil)
            }
        }
    }
    
    func getStudentLocation (_ uniqueKey: Int, _ completionHandler:@escaping (StudentInformation?,_ error: String?)->Void) {
        
        let url = ApiHelper.Base.parse + ApiHelper.Extras.studentLocation
        
        let WHERE =  "{\"uniqueKey\":\"\(uniqueKey)\"}".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let parameters = [
            "where" : WHERE ,
            "limit" : "100"]
        
        let headers = [
            "X-Parse-Application-Id": ApiHelper.Constants.parseAppId,
            "X-Parse-REST-API-Key": ApiHelper.Constants.parseApiKey
        ]
        let client = "parse"
        
        get(url, parameters as [String : AnyObject], headers,client) { (data, error) in
            if let error = error {
                completionHandler(nil,error.localizedDescription)
            }
            
            guard let data = data else {
                completionHandler(nil,error?.localizedDescription)
                return
            }
            
            if let results = data["results"] as? [[String:AnyObject]] {
                for result in results {
                    completionHandler(StudentInformation(dictionary: result),nil)
                }
            }
        }
    }
    
    func publishLocation (uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaUrl: String, latitude: Double, longitude: Double, _ completionHandler: @escaping(_ error:String?)-> Void) {
        
        let url = ApiHelper.Base.parse + ApiHelper.Extras.studentLocation
        let headers = [
            "X-Parse-Application-Id": ApiHelper.Constants.parseAppId,
            "X-Parse-REST-API-Key": ApiHelper.Constants.parseApiKey,
            "Content-Type" : "application/json"
        ]
        let jsonBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaUrl)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        let client = "parse"
        
        post(url, jsonBody, headers,client) { (data, error) in
            if error != nil {
                completionHandler(error?.localizedDescription)
            }
            completionHandler(nil)
        }
    }
    
    func updateLocation (objectID: String, uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaUrl: String, latitude: Double, longitude: Double, _ completionHandler: @escaping(_ error:String?)-> Void) {
        
        let url = ApiHelper.Base.parse + ApiHelper.Extras.studentLocation + "/" + objectID
        
        let jsonBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaUrl)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
       
        let headers = [
            "X-Parse-Application-Id": ApiHelper.Constants.parseAppId,
            "X-Parse-REST-API-Key": ApiHelper.Constants.parseApiKey,
            "Content-Type" : "application/json"
        ]
        
        let client = "parse"
        
        put(url, jsonBody, headers, client) { (data, error) in
            if error != nil {
                completionHandler(error?.localizedDescription)
            }
            completionHandler(nil)
        }
    }
    
    class func sharedInstance () -> ParseApiClient {
        struct Singleton {
            static let sharedInstance =  ParseApiClient()
        }
        return Singleton.sharedInstance
    }
}
