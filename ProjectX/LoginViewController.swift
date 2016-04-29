//
//  LoginViewController.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 3/10/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    var user: User?
    var loggingIn: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // user defaults
        let prefs = NSUserDefaults.standardUserDefaults()
        
        // get user from UserDefaults
        if let decoded = prefs.objectForKey("user") as? NSData {
            if let decodedUser = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as? User {
                user = decodedUser
            }

        }

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // if already logged in, go to eventVC
        if(FBSDKAccessToken.currentAccessToken() != nil && user != nil && !loggingIn)
        {
            self.performSegueWithIdentifier("Login", sender: nil)
        }
    }

    // do facebook login when button is touched, then go to next VC
    @IBAction func loginButtonTouch(sender: AnyObject) {
        FacebookClient.sharedInstance().login(self) {
            (user) in
            if self.user == nil {
                self.user = user
                self.loggingIn = true
                self.performSegueWithIdentifier("Login", sender: nil)
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if user == nil || FBSDKAccessToken.currentAccessToken() == nil{
            return false
        }
        return true
    }

    // give the eventVC the current user
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tabBarVC = segue.destinationViewController as! UITabBarController
        let navVC = tabBarVC.viewControllers?.first as! UINavigationController
        let eventVC = navVC.viewControllers.first as! EventViewController
        
        eventVC.user = self.user
        self.loggingIn = false
    }
}
