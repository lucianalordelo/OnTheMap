//
//  ListViewController.swift
//  OnTheMapApp
//
//  Created by Luciana Lordelo Nascimento on 19/10/2018.
//  Copyright © 2018 Luciana Lordelo Nascimento. All rights reserved.
//

import Foundation
import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.delegate = self
        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain , target: self, action: #selector (logoutPressed))
        tabBarController?.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "icon_pin"), style: .plain, target: self, action: #selector(postPin)), UIBarButtonItem(image: UIImage(named: "icon_refresh"), style: .plain, target: self, action: #selector (refresh))]
        navigationItem.title = "On the Map"
    }
    
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
            performSegue(withIdentifier: "addVC", sender: self)
        }
        
        if (UIApplication.shared.delegate as! AppDelegate).currentStudentInformation != nil {
            let alertcontroller = UIAlertController(title: "Overwrite?", message: "Overwrite previous location posted?", preferredStyle: .alert)
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (alertAction) in
                presentNextVC()
            }
            alertcontroller.addAction(noAction)
            alertcontroller.addAction(yesAction)
            present(alertcontroller,animated: true, completion: nil)
        } else{
            presentNextVC()
        }
    }
    
    @objc func refresh() {
        loadData()
    }
    
    //MARK: TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformations.data.count
    }
    //MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseID = "identifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID)
        let student = StudentInformations.data[indexPath.row]
        
        if let name = cell?.textLabel {
            name.text = "\(student.firstName) \(student.lastName)"
            cell?.imageView?.image = UIImage(named: "icon_pin")
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = StudentInformations.data[indexPath.row]
        let url = URL(string: student.mediaUrl)
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            self.present(HelperMethods.alertController(title: "No URL provided", message: "Select another student"), animated: true, completion: nil)
            
        }
    }
    
    
    //MARK : Helpers
    func loadData(){
        
        ParseApiClient.sharedInstance().getLocations { (arrayOfLocations, error) in
            
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
            }
        }
    }
}
