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
    
    //let ref = Firebase(url: "https://amber-inferno-4463.firebaseio.com/users/")
    var authID: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = self.view.center
        loginButton.delegate = self
        
        self.view.addSubview(loginButton)
        
*/
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
            self.performSegueWithIdentifier("NavController", sender: nil)

        }

    }
    
    // MARK: - Facebook Login
/*
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        //when user logs in
        
        if(error == nil)
        {
            print("login complete")
       //     let nextVC = storyboard!.instantiateViewControllerWithIdentifier("NavController") as! UINavigationController

         //   self.presentViewController(nextVC, animated: true, completion: nil)
        }
        else
        {
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        //when user logs out
        print("user logged out")
        
        let ref2 = Firebase(url: "https://amber-inferno-4463.firebaseio.com/")
        ref2.unauth()
    }
*/

    @IBAction func loginButtonTouch(sender: AnyObject) {
        FacebookClient.sharedInstance().login(self) {
            (authID) in
            self.authID = authID
        }
        /*
        let facebookLogin = FBSDKLoginManager()

        facebookLogin.logInWithReadPermissions(["public_profile","email", "user_friends"], fromViewController: self ,handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                self.ref.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in! \(authData)")
                            
                            

                            
                            //store data onto firebase
                            
                            let user = User(name: authData.providerData["displayName"] as! String)
                            
                            self.authID = authData.uid
                            
                            
                            let prefs = NSUserDefaults.standardUserDefaults()
                            prefs.setValue(self.authID, forKey: "authID")

        
                            // updates user reference
                            let userRef = self.ref.childByAppendingPath(self.authID)
                            userRef.updateChildValues(["name": user.name, "userid": self.authID!])
                        
                            //let nextVC = self.storyboard!.instantiateViewControllerWithIdentifier("NavController") as! UINavigationController

                           // self.presentViewController(nextVC, animated: true, completion: nil)
                            //self.performSegueWithIdentifier("NavController", sender: nil)
                            
                        }
                })
            }
        })
*/
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
        let navVC = segue.destinationViewController as! UINavigationController
        
        let eventVC = navVC.viewControllers.first as! EventViewController
            eventVC.authID = authID
    }
}
