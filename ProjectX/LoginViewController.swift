//
//  LoginViewController.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/10/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = self.view.center
        loginButton.delegate = self
        
        self.view.addSubview(loginButton)
        */
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
   /*
        if(FBSDKAccessToken.currentAccessToken() == nil)
        {
            print("not logged in")
        }
        else
        {
            print("logged in")
            let nextVC = storyboard!.instantiateViewControllerWithIdentifier("NavController") as! UINavigationController
            self.presentViewController(nextVC, animated: true, completion: nil)
        }
*/
    }
    
    // MARK: - Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        //when user logs in
        
        if(error == nil)
        {
            print("login complete")
            let nextVC = storyboard!.instantiateViewControllerWithIdentifier("NavController") as! UINavigationController

            self.presentViewController(nextVC, animated: true, completion: nil)
        }
        else
        {
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        //when user logs out
        print("user logged out")
    }
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
    }
    
    
    
    @IBAction func signupButtonTouch(sender: AnyObject) {
    }
}
