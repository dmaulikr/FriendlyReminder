//
//  LoginViewController.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/10/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import Firebase
//import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var authID: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // user defaults
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if let data = prefs.stringForKey("authID") {
            authID = data
        }else{
            //Nothing stored in NSUserDefaults yet. Set a value.
            print("no data found")
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // if already logged in, go to eventVC
   
        if(FBSDKAccessToken.currentAccessToken() == nil || authID == nil)
        {
            print("not logged in")
        }
        else
        {
            print("logged in")
            self.performSegueWithIdentifier("Login", sender: nil)

        }

    }

    @IBAction func loginButtonTouch(sender: AnyObject) {
        FacebookClient.sharedInstance().login(self) {
            (authID) in
            self.authID = authID
        }
    }
    
    
    
    @IBAction func signupButtonTouch(sender: AnyObject) {
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if self.authID == nil || FBSDKAccessToken.currentAccessToken() == nil{
            return false
        }
        return true
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {        
        
        let tabBarVC = segue.destinationViewController as! UITabBarController
        let navVC = tabBarVC.viewControllers?.first as! UINavigationController
        let eventVC = navVC.viewControllers.first as! EventViewController
        
        eventVC.authID = authID
    }
    
}
