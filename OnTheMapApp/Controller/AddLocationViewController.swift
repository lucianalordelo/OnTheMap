//
//  PostViewController.swift
//  OnTheMapApp
//
//  Created by Luciana Lordelo Nascimento on 17/10/2018.
//  Copyright © 2018 Luciana Lordelo Nascimento. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class AddLocationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var locationTextField : UITextField!
    @IBOutlet weak var findbutton: UIButton!
    
    var locationData = LocationData()
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func findLocation(_ sender: Any) {
        if locationTextField.text == "" {
            self.present(HelperMethods.alertController(title: "Error", message: "type a location"), animated: true, completion: nil)
        } else {
            locationData.locationText = locationTextField.text!
            //Get the latitude and longitude
            getTypedLocation { (error) in
                if error != nil {
                    performUpdatesOnMain {
                        self.present(HelperMethods.alertController(title: "Error", message: "Could not find location"), animated: true, completion: nil)
                    }
                    
                } else {
                    self.performSegue(withIdentifier: "confirmVC", sender: self)
                }
            }
        }
    }
    
    
    func getTypedLocation(completionHandler: @escaping (_ error: String?)-> Void) {
        
        performUpdatesOnMain {
            HelperMethods.startActivityIndicator(self.view, activityIndicator: self.activityIndicator)
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationTextField.text!) { (placemarks, error) in
            if error != nil{
                self.present(HelperMethods.alertController(title: "Place not found", message: "Try  again"), animated: true, completion: nil)
            }
            
            guard let placemarks = placemarks else {
                completionHandler(error?.localizedDescription)
                return
            }
            
            guard let latitude = placemarks[0].location?.coordinate.latitude else{
                completionHandler(error?.localizedDescription)
                return
            }
            
            guard let longitude = placemarks[0].location?.coordinate.longitude else{
                completionHandler(error?.localizedDescription)
                return
            }
            
            self.locationData.latitude = latitude
            self.locationData.longitude = longitude
            completionHandler(nil)
            performUpdatesOnMain {
                HelperMethods.stopActivityIndicator(self.view, activityIndicator: self.activityIndicator)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmVC" {
            let controller = segue.destination as! ConfirmLocationViewController
            controller.locationData = self.locationData
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
        if let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey]) as? NSValue {
            if view.frame.origin.y == 0{
                view.frame.origin.y -= (keyboardSize.cgRectValue.height)/2
            }
        }
    }
    
    @objc func keyboardWillHide (_ notification: Notification) {
        if let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey]) as? NSValue {
            if view.frame.origin.y != 0{
                view.frame.origin.y += (keyboardSize.cgRectValue.height)/2
            }
        }
    }
    //Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        findLocation(findbutton)
        return true
    }
}
