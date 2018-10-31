//
//  UdacityApiClient.swift
//  OnTheMapApp
//
//  Created by Luciana Lordelo Nascimento on 05/10/2018.
//  Copyright © 2018 Luciana Lordelo Nascimento. All rights reserved.
//

import Foundation
import UIKit

class UdacityApiClient: Client{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func login(email: String, password: String, completionHandlerForLogin: @escaping( _ accountKey:Int?,_ sessionID: String?, _ error: String?)->Void) {
        
        let url = ApiHelper.Base.udacity + ApiHelper.Extras.session
        let jsonBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        let headers = [
            "Accept":"application/json",
            "Content-Type": "application/json"
        ]
        let client = "udacity"
        
        post(url, jsonBody, headers, client) { (data, error) in
            if let error = error {
                completionHandlerForLogin(nil, nil,error.localizedDescription)
            }else {
                let account = data!["account"] as? [String:AnyObject]
                let session = data!["session"] as? [String:AnyObject]
                
                if account != nil, session != nil {
                    let accountKey = Int((account!["key"] as? String)!)
                    let sessionID = session!["id"] as? String
                    completionHandlerForLogin(accountKey, sessionID, nil)
                }
            }
        }
    }
    
    func logout (_ completionHandlerForLogout: @escaping(String?)->Void){
        
        let url = ApiHelper.Base.udacity + ApiHelper.Extras.session
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        guard let cookie = xsrfCookie else {
            completionHandlerForLogout("No Cookie Found")
            return
        }
        let headers = ["X-XSRF-TOKEN": cookie.value]
        let client = "udacity"
        
        delete(url, headers, client) { (data, error) in
            if let error = error {
                completionHandlerForLogout(error.localizedDescription)
                return
            }
            completionHandlerForLogout(nil)
        }
    }
    
    func getUserPublicData(_ id: String, _ completionHandlerForPublicData: @escaping(String?)->Void) {
        
        let url = ApiHelper.Base.udacity + ApiHelper.Extras.users + "/\(id)"
        let parameters = [String:AnyObject]()
        let headers = [String:String] ()
        let client = "udacity"
        
        get(url, parameters, headers, client) { (data, error) in
            if let error = error{
                completionHandlerForPublicData(error.localizedDescription)
                return
            }
            
            guard let data = data else{
                completionHandlerForPublicData ("Unable to get data")
                return
            }
            
            guard let user = data["user"] as? [String:Any] else{
                completionHandlerForPublicData("No key 'user' found")
                return
            }
            
            guard let firstName = user["first_name"] as? String else{
                completionHandlerForPublicData("No key 'first_name' found")
                return
            }
            
            guard let lastName = user["last_name"] as? String else{
                completionHandlerForPublicData("No key 'last_name' found")
                return
            }
            
            self.appDelegate.firstName = firstName
            self.appDelegate.lastName = lastName
            
        }
    }
    
    class func sharedInstance () -> UdacityApiClient {
        struct Singleton {
            static let sharedInstance = UdacityApiClient()
        }
        return Singleton.sharedInstance
    }
}
