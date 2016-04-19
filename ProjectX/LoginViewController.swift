//
//  LoginViewController.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/10/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    var authID: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // user defaults
        let prefs = NSUserDefaults.standardUserDefaults()
        
        // get authID from UserDefaults
        if let data = prefs.stringForKey("authID") {
            authID = data
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // if already logged in, go to eventVC
        if(FBSDKAccessToken.currentAccessToken() != nil && authID != nil)
        {
            self.performSegueWithIdentifier("Login", sender: nil)
        }
    }

    // do facebook login when button is touched, then go to next VC
    @IBAction func loginButtonTouch(sender: AnyObject) {
        FacebookClient.sharedInstance().login(self) {
            (authID) in
            if self.authID == nil {
                self.authID = authID
                self.performSegueWithIdentifier("Login", sender: nil)
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if self.authID == nil || FBSDKAccessToken.currentAccessToken() == nil{
            return false
        }
        return true
    }

    // give the eventVC the user's authID
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tabBarVC = segue.destinationViewController as! UITabBarController
        let navVC = tabBarVC.viewControllers?.first as! UINavigationController
        let eventVC = navVC.viewControllers.first as! EventViewController
        
        eventVC.authID = authID
    }
}
