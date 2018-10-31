//
//  PostViewController.swift
//  OnTheMapApp
//
//  Created by Luciana Lordelo Nascimento on 17/10/2018.
//  Copyright © 2018 Luciana Lordelo Nascimento. All rights reserved.
//

import Foundation
import UIKit

class PostViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var locationTextField : UITextField!
    @IBOutlet weak var backButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        
    }
    
    @IBAction func backToMain(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "navigationController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func findLocation(_ sender: Any) {
        if locationTextField.text == "" {
            HelperMethods.alertController(title: "Error", message: "Type a location")
        }
            
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let studentLocation = appDelegate.currentStudentInformation {
              
                let studentInfo = StudentInformation(dictionary: [
                    "ObjectID":studentLocation.ObjectID as AnyObject,
                    "UniqueKey":"\(appDelegate.accountKey)" as AnyObject,
                    "FirstName": "\(appDelegate.firstName)" as AnyObject,
                    "LastName" : "\(appDelegate.lastName)" as AnyObject,
                    "MapString" : locationTextField.text! as AnyObject,
                    "MediaURL" : studentLocation.MediaURL as AnyObject,
                    "Latitude" : 0 as AnyObject,
                    "Longitude" : 0 as AnyObject
                    ])
                //Uses post method
                ParseApiClient.sharedInstance().updateLocation(studentInfo!) { (error) in
                    if let error = error {
                        performUpdatesOnMain {
                            
                            self.present(HelperMethods.alertController(title: "Error", message: error), animated: true, completion: nil)
                            
                        }
                    }
                }
            } else {
                let studentInfo = StudentInformation(dictionary: [
                    "ObjectID":appDelegate.sessionId as AnyObject,
                    "UniqueKey":"\(appDelegate.accountKey)" as AnyObject,
                    "FirstName": "\(appDelegate.firstName)" as AnyObject,
                    "LastName" : "\(appDelegate.lastName)" as AnyObject,
                    "MapString" : locationTextField.text! as AnyObject,
                    "MediaURL" : "no url" as AnyObject,
                    "Latitude" : 0 as AnyObject,
                    "Longitude" : 0 as AnyObject
                    ])
                //Used put method
                ParseApiClient.sharedInstance().publishLocation(studentInfo!) { (error) in
                    if let error = error {
                        performUpdatesOnMain {
                            
                            self.present(HelperMethods.alertController(title: "Error", message: error), animated: true, completion: nil)
                            
                        }
                    }
                }
            }
        }
    
    //Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
