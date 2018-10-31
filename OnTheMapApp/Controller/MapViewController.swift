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
    
    //Outlet:
    @IBOutlet weak var mapView : MKMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView?.delegate = self
        
    }
    
    @IBAction func logoutPressed () {
        print("teste")
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
    
    
    
    
    //MARK: MapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKAnnotationView (annotation: annotation, reuseIdentifier: reuseID) as! MKPinAnnotationView
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView?.pinTintColor = .red
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation, let subtitle = annotation.subtitle else {
            return
        }
        let url = URL(string: subtitle!)
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
    //MARK : Helpers
    func loadData(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ParseApiClient.sharedInstance().getLocations { (arrayOfLocations, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            guard let error = error else {
                performUpdatesOnMain {
                    HelperMethods.alertController(title: "Error", message: "An error has occured")
                }
                return
            }
            
            guard let arrayOfLocations = arrayOfLocations else {
                performUpdatesOnMain {
                    HelperMethods.alertController(title: "Error", message: error)
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
            annotation.title = item.FirstName! + "" + item.LastName!
            annotation.coordinate = CLLocationCoordinate2DMake(item.Latitude!, item.Longitude!)
            annotation.subtitle? = ""
            annotations.append(annotation)
        }
        mapView?.addAnnotations(annotations)
    }
    
}
