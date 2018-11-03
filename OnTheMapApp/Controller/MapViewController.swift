//
//  ViewController.swift
//  OnTheMapApp
//
//  Created by Luciana Lordelo Nascimento on 16/10/2018.
//  Copyright © 2018 Luciana Lordelo Nascimento. All rights reserved.
//

import UIKit

import Foundation
import UIKit
import MapKit



class MapViewController: UIViewController, MKMapViewDelegate  {
    
    @IBOutlet weak var mapView : MKMapView?
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView?.delegate = self
        loadData()
        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain , target: self, action: #selector (logoutPressed))
        tabBarController?.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "icon_pin"), style: .plain, target: self, action: #selector(postPin)), UIBarButtonItem(image: UIImage(named: "icon_refresh"), style: .plain, target: self, action: #selector (refresh))]
        navigationItem.title = "On the Map"
    }
    
    //MARK: Selectors
    @objc func logoutPressed () {
        UdacityApiClient.sharedInstance().logout { (error) in
            performUpdatesOnMain {
                if let error = error {
                    let alert = HelperMethods.alertController(title: "Error", message: error)
                    self.present(alert, animated: true, completion: nil)
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func postPin () {
        
        func presentNextVC () {
            performSegue(withIdentifier: "addVC", sender: UINavigationController.self)
        }
        
        if (UIApplication.shared.delegate as! AppDelegate).currentStudentInformation != nil {
            let alertcontroller = UIAlertController(title: "Overwrite?", message: "Overwrite previous location posted?", preferredStyle: .alert)
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (alertAction) in
                presentNextVC()
            }
            alertcontroller.addAction(yesAction)
            alertcontroller.addAction(noAction)
            present(alertcontroller,animated: true, completion: nil)
        } else{
            presentNextVC()
        }
    }
    
    @objc func refresh() {
        loadData()
    }
    
    
    //MARK: MapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView?.pinTintColor = .red
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        guard let annotation = view.annotation else {
            return
        }
        guard let subtitle = annotation.subtitle else{
            return
        }
        let url = URL(string: subtitle!)
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
    
    //MARK : Helpers
    func loadData(){
        
        HelperMethods.startActivityIndicator(self.view, activityIndicator: self.activityIndicator)
        
        ParseApiClient.sharedInstance().getLocations { (arrayOfLocations, error) in
            
            performUpdatesOnMain {
                HelperMethods.stopActivityIndicator(self.view, activityIndicator: self.activityIndicator)
            }
            
            if let error = error {
                performUpdatesOnMain {
                    self.present(HelperMethods.alertController(title: "Error", message: error), animated: true, completion: nil)
                }
            }
            
            guard let arrayOfLocations = arrayOfLocations else {
                performUpdatesOnMain {
                    self.present(HelperMethods.alertController(title: "Error", message: "Unable to get student locations"), animated: true, completion: nil)
                }
                return
            }
            
            performUpdatesOnMain {
                StudentInformations.data = arrayOfLocations
                self.updateMap()
            }
        }
    }
    
    func updateMap() {
        
        mapView?.removeAnnotations((mapView?.annotations)!)
        var annotations = [MKPointAnnotation]()
        
        for item in StudentInformations.data {
            let annotation = MKPointAnnotation()
            annotation.title = item.firstName + " " + item.lastName
            annotation.coordinate = CLLocationCoordinate2DMake(item.latitude, item.longitude)
            annotation.subtitle = item.mediaUrl
            annotations.append(annotation)
        }
        mapView?.addAnnotations(annotations)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
