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
    var returningUser: Bool = false
    var newUser: Bool = false

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
        
        // if already logged in, go to eventVC
        if(FBSDKAccessToken.currentAccessToken() != nil && user != nil)
        {
            self.returningUser = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if returningUser {
            self.performSegueWithIdentifier("Login", sender: nil)
        } else {
            newUser = true
        }
    }

    // do facebook login when button is touched
    @IBAction func loginButtonTouch(sender: AnyObject) {
        
        let group = dispatch_group_create()
        dispatch_group_enter(group)

        FacebookClient.sharedInstance().login(self) {
            user in
            self.user = user
            dispatch_group_leave(group)
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            if self.newUser {
                self.performSegueWithIdentifier("Login", sender: nil)
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if user == nil || FBSDKAccessToken.currentAccessToken() == nil {
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
        returningUser = false
        newUser = false
    }
}
