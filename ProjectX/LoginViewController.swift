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
    var doSegue: Bool = false
    var condition: Bool = false

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
            self.doSegue = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if doSegue && condition == false {
            self.performSegueWithIdentifier("Login", sender: nil)
        } else {
            // this condition acts as an indicator of when viewDidAppear
            // executes before Facebook returns from it's completionHandler.
            // Condition is true when viewDidAppear executes before FB login is done
            condition = true
        }
    }

    // do facebook login when button is touched
    @IBAction func loginButtonTouch(sender: AnyObject) {
        let group = dispatch_group_create()
        condition = false
        dispatch_group_enter(group)

        FacebookClient.sharedInstance().login(self) {
            user in
            self.user = user
            self.doSegue = true
            dispatch_group_leave(group)
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            // this segue gets executed on the first time logging into facebook
            // viewDidAppear executes before the FB call is finished therefore
            // not calling the segue. In future logins the segue in viewDidAppear
            // gets executed because the completion handler is able to finish
            // before viewDidAppear gets called
            if self.condition {
                self.condition = false
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
        doSegue = false
    }
}
