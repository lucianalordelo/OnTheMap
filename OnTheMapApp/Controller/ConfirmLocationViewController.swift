//
//  ConfirmLocationViewController.swift
//  OnTheMapApp
//
//  Created by Luciana Lordelo Nascimento on 22/10/2018.
//  Copyright © 2018 Luciana Lordelo Nascimento. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ConfirmLocationViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    var locationData = LocationData()
    var annotation = MKPointAnnotation()
    
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var urlTextField : UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setAnnotations()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        urlTextField.delegate = self
    }
    
    func setAnnotations() {
        //Coordinates
        let coordinates = CLLocationCoordinate2D(latitude: locationData.latitude, longitude: locationData.longitude)
        
        //Map region
        let region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
        self.mapView.setRegion(region, animated: true)
        
        //Annotation
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let title = "\(appDelegate.firstName)" + " " + "\(appDelegate.lastName)"
        let subtitle = urlTextField.text ?? "No URL Provided"
        annotation.title = title
        annotation.coordinate = coordinates
        annotation.subtitle = subtitle
        
        
        //Set annotation
        self.mapView.addAnnotation(self.annotation)
        
    }
    
    @IBAction func submit() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let currentStudentInfo = appDelegate.currentStudentInformation {
            
            //method update location called when user wants to overwrite a location
            ParseApiClient.sharedInstance().updateLocation(objectID: currentStudentInfo.objectId ,uniqueKey: "\(appDelegate.accountKey!)", firstName: appDelegate.firstName, lastName: appDelegate.lastName, mapString: "\(locationData.locationText)", mediaUrl: "\(urlTextField.text!)", latitude: locationData.latitude, longitude: locationData.longitude) { (error) in

            
                if error != nil {
                    performUpdatesOnMain {
                        self.present(HelperMethods.alertController(title: "Error", message: "unable to update location"), animated: true, completion: nil)
                    }
                }
                performUpdatesOnMain {
                    self.navigationController?.popToRootViewController(animated: true)
                }
                
            }
        } else {
            //let info = StudentInformation(objectId: "", uniqueKey: "\(appDelegate.accountKey!)", firstName: "\(appDelegate.firstName)", lastName: "\(appDelegate.lastName)", mapString: "\(locationData.locationText)", mediaUrl: "\(urlTextField.text!)", latitude: locationData.latitude, longitude: locationData.longitude)
            
            //First map posting
            ParseApiClient.sharedInstance().publishLocation(uniqueKey: "\(appDelegate.accountKey!)", firstName: appDelegate.firstName, lastName: appDelegate.lastName, mapString: locationData.locationText, mediaUrl: urlTextField.text!, latitude: locationData.latitude, longitude: locationData.longitude) { (error) in
                if error != nil {
                    performUpdatesOnMain {
                        self.present(HelperMethods.alertController(title: "Error", message: "unable to update location"), animated: true, completion: nil)
                    }
                }
                performUpdatesOnMain {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    //Configure keyboard appearance
    func subscribeToKeyboardNotifications () {
        NotificationCenter.default.addObserver(self, selector: #selector (keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: self)
    }
    
    func unsubscribeFromKeyboardNotifications () {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyBoardWillShow (_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    @objc func keyboardWillHide (_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    //Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
