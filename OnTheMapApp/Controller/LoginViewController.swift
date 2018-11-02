//
//  ViewController.swift
//  OnTheMapApp
//
//  Created by Luciana Lordelo Nascimento on 04/10/2018.
//  Copyright © 2018 Luciana Lordelo Nascimento. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Variables
    @IBOutlet weak var email : UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton : UIButton!
    @IBOutlet weak var loginLabel : UILabel!
    
    var activityIndicator = UIActivityIndicatorView()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email.delegate = self
        password.delegate = self
        password.isSecureTextEntry = true
        email.tag = 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        configureUI(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: Login to udacity
    @IBAction func UdacityLogin(_ sender: Any) {
        
        if email.text == "" || password.text == ""{
            present(HelperMethods.alertController(title: "Incorrect email or password", message: "Enter your email and password"), animated: true, completion: nil)
        }
        
        HelperMethods.startActivityIndicator(self.view, activityIndicator: self.activityIndicator)
        
        //get accountKey and sessionID
        UdacityApiClient.sharedInstance().login(email: email.text!, password: password.text!) { (accountKey, sessionID, error) in
            
            performUpdatesOnMain {
                self.configureUI(false)
                HelperMethods.stopActivityIndicator(self.view, activityIndicator: self.activityIndicator)
            }
            
            guard let sessionID = sessionID, let accountKey = accountKey else{
                performUpdatesOnMain {
                    self.present(HelperMethods.alertController(title: "Login error", message: "Unable to complete login: \(error!)"), animated: true, completion: nil)
                    self.configureUI(true)
                }
                return
            }
            
            self.appDelegate.sessionId = sessionID
            self.appDelegate.accountKey = accountKey
            
            //Get student Location, if any
            ParseApiClient.sharedInstance().getStudentLocation(accountKey) { (studentInfo, error) in
                guard error == nil else {
                    return
                }
                self.appDelegate.currentStudentInformation = studentInfo
                
            }
            
            //get first and last name
            UdacityApiClient.sharedInstance().getUserPublicData("\(accountKey)", { (error) in
                
            })
            
            performUpdatesOnMain {
                self.completeLogin()
            }
        }
    }
    
    @IBAction func signup(_ sender: Any) {
        let url = URL(string: "https://www.udacity.com/account/auth#!/signup")
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
    //MARK: Helpers
    
    //Enable or Hide UIElements
    
    func completeLogin() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "navigationController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
    
    func configureUI (_ Enabled: Bool){
        loginButton.isEnabled = Enabled
        password.isEnabled = Enabled
        email.isEnabled = Enabled
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
    
    //TextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //email.tag == 100 . after pressing return, passwordtextfield becomes first responder
        if textField.tag == 100 {
            password.becomeFirstResponder()
            return true
        }
        //after pressing return (password), udacity login is called
        textField.resignFirstResponder()
        UdacityLogin(loginButton)
        return true
    }
    
}

