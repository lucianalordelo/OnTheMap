//
//  Client.swift
//  OnTheMapApp
//
//  Created by Luciana Lordelo Nascimento on 04/10/2018.
//  Copyright © 2018 Luciana Lordelo Nascimento. All rights reserved.
//

import Foundation

class Client {
    
    func get(_ url:String, _ parameters: [String:AnyObject],_ headers: [String:String]!,_ client: String,_ completionHandlerForGet: @escaping (_ data: AnyObject?,_ error: NSError?)->Void) {
        
        var arrayOfParameters = [String]()
        
        for (key,value) in parameters {
            arrayOfParameters.append("\(key)=\(value)")
        }
        
        guard let completeURL = URL(string: url + "?" + arrayOfParameters.joined(separator: "&")) else {
            completionHandlerForGet(nil,NSError(domain: "get", code: 0, userInfo: [NSLocalizedDescriptionKey:"InvalidURL"]))
            return
        }
        
        var request = URLRequest(url: completeURL)
        request.httpMethod = "GET"
        
        if let headers = headers {
            for (key,value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard (error==nil) else{
                completionHandlerForGet(nil,NSError(domain: "GET", code: 0, userInfo: [NSLocalizedDescriptionKey:"There was an error with your request"]))
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForGet(nil, NSError(domain: "GET", code: 0, userInfo: [NSLocalizedDescriptionKey:"Your request return a response other than 2XX"]))
                return
            }
            
            guard let data = data else{
                completionHandlerForGet(nil, NSError(domain: "GET", code: 0, userInfo: [NSLocalizedDescriptionKey:"Could not find data"]))
                return
            }
            
            // First Five characters are for security reasons, let's jump them
            if client == "udacity" {
                let range = Range(5 ..< data.count)
                let newData = data.subdata(in: range)
                self.convertDataForJSON(newData, completionHandlerForConvertData: completionHandlerForGet)
            }else{
                self.convertDataForJSON(data, completionHandlerForConvertData: completionHandlerForGet)
            }
        }
        
        task.resume()
        
    }
    
    func post(_ url:String,_ jsonBody:String,_ headers: [String:String]!,_ client: String, completionHandlerForPost:@escaping (_ data:AnyObject?,_ error: NSError?)->Void){
        
        guard let completeURL = URL(string: url) else{
            completionHandlerForPost(nil,NSError(domain: "POST", code: 0, userInfo: [NSLocalizedDescriptionKey:"Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: completeURL)
        request.httpMethod = "POST"
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        if let headers = headers {
            for (key,value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard (error==nil) else{
                completionHandlerForPost(nil,NSError(domain: "delete", code: 0, userInfo: [NSLocalizedDescriptionKey:"There was an error with your request"]))
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                if ((response as? HTTPURLResponse)?.statusCode == 403) {
                    completionHandlerForPost(nil,NSError(domain: "Post", code: 0, userInfo: [NSLocalizedDescriptionKey:"Invalid Credentials"]))
                    return
                } else{
                    completionHandlerForPost(nil,NSError(domain: "Post", code: 0, userInfo: [NSLocalizedDescriptionKey:"Your request return a response other than 2XX"]))
                    return
                }
            }
            
            guard let data = data else{
                completionHandlerForPost(nil,NSError(domain: "Post", code: 0, userInfo: [NSLocalizedDescriptionKey:"Could not find data"]))
                return
            }
            
            if client == "udacity" {
                // First Five characters are for security reasons, let's jump them
                let range = Range(5 ..< data.count)
                let newData = data.subdata(in: range)
                self.convertDataForJSON(newData, completionHandlerForConvertData: completionHandlerForPost)
            } else {
                self.convertDataForJSON(data, completionHandlerForConvertData: completionHandlerForPost)
            }
            
            
            
        }
        
        task.resume()
        
    }
    
    func put(_ url:String,_ jsonBody:String,_ headers: [String:String]!,_ client: String, completionHandlerForPut:@escaping (_ data:AnyObject?,_ error: NSError?)->Void){
        
        guard let completeURL = URL(string: url) else {
            completionHandlerForPut(nil,NSError(domain: "PUT", code: 0, userInfo: [NSLocalizedDescriptionKey:"Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: completeURL)
        request.httpMethod = "PUT"
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        if let headers = headers {
            for (key,value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard (error==nil) else{
                completionHandlerForPut(nil,NSError(domain: "delete", code: 0, userInfo: [NSLocalizedDescriptionKey:"There was an error with your request"]))
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForPut(nil,NSError(domain: "delete", code: 0, userInfo: [NSLocalizedDescriptionKey:"Your request return a response other than 2XX"]))
                return
            }
            
            guard let data = data else{
                completionHandlerForPut(nil,NSError(domain: "delete", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find data"]))
                return
            }
            
            if client == "udacity" {
                // First Five characters are for security reasons, let's jump them
                let range = Range(5 ..< data.count)
                let newData = data.subdata(in: range)
                self.convertDataForJSON(newData, completionHandlerForConvertData: completionHandlerForPut)
            } else{
                self.convertDataForJSON(data, completionHandlerForConvertData: completionHandlerForPut)
            }
            
        }
        
        task.resume()
        
    }
    
    func delete (_ url: String,_ headers: [String:String]!, _ client: String, completionHandlerForDelete : @escaping (_ data:AnyObject?, _ error: NSError?)->Void) {
        
        guard let completeURL = URL(string: url) else{
            completionHandlerForDelete(nil,NSError(domain: "DELETE", code: 0, userInfo: [NSLocalizedDescriptionKey:"Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: completeURL)
        request.httpMethod = "DELETE"
        
        if let headers = headers {
            for (key,value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data,response, error) in
            
            guard (error==nil) else{
                completionHandlerForDelete(nil,NSError(domain: "delete", code: 0, userInfo: [NSLocalizedDescriptionKey:"There was an error with your request"]))
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForDelete(nil,NSError(domain: "delete", code: 0, userInfo: [NSLocalizedDescriptionKey:"Your request return a response other than 2XX"]))
                return
            }
            
            guard let data = data else{
                completionHandlerForDelete(nil,NSError(domain: "delete", code: 0, userInfo: [NSLocalizedDescriptionKey:"Could not find data"]))
                return
            }
            
            if client == "udacity" {
                // First Five characters are for security reasons, let's jump them
                let range = Range(5 ..< data.count)
                let newData = data.subdata(in: range)
                self.convertDataForJSON(newData, completionHandlerForConvertData: completionHandlerForDelete)
            }else{
                self.convertDataForJSON(data, completionHandlerForConvertData: completionHandlerForDelete)
            }
            
        }
        
        task.resume()
        
    }
    
    private func convertDataForJSON (_ data:Data, completionHandlerForConvertData: (_ data: AnyObject?,_ error: NSError?) -> Void) {
        var parsedResult : AnyObject! = nil
        do{
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        }catch{
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: \(data)"]
            completionHandlerForConvertData(nil,NSError(domain: "ConvertDataForJSON", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult,nil)
    }
}
