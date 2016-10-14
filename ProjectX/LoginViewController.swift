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

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var appTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // user defaults
        let prefs = UserDefaults.standard
        
        // get user from UserDefaults
        if let decoded = prefs.object(forKey: "user") as? Data {
            if let decodedUser = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? User {
                user = decodedUser
            }
        }
        
        // if already logged in, go to eventVC
        if(FBSDKAccessToken.current() != nil && user != nil)
        {
            self.returningUser = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if returningUser {
            self.performSegue(withIdentifier: "Login", sender: nil)
        } else {
            newUser = true
            animView()
        }
    }

    // do facebook login when button is touched
    @IBAction func loginButtonTouch(_ sender: AnyObject) {
        
        let group = DispatchGroup()
        group.enter()

        FacebookClient.sharedInstance().login(self) {
            user in
            self.user = user
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            if self.newUser {
                self.performSegue(withIdentifier: "Login", sender: nil)
            }
        }
    }
    
    func animView() {
        appTitle.alpha = 0.0
        loginButton.frame.origin.y += self.view.bounds.height
        UIView.animate(withDuration: 3.0, animations: {
            self.appTitle.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 2.0, delay: 0.0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
                self.loginButton.frame.origin.y -= self.view.bounds.height
            }, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if user == nil || FBSDKAccessToken.current() == nil {
            return false
        }
        return true
    }

    // give the eventVC the current user
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabBarVC = segue.destination as! UITabBarController
        let navVC = tabBarVC.viewControllers?.first as! UINavigationController
        let eventVC = navVC.viewControllers.first as! EventViewController
        
        eventVC.user = self.user
        returningUser = false
        newUser = false
    }
}
