//
//  FacebookClient.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 3/16/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class FacebookClient {
    
    func login(controller: UIViewController, completionHandler: (user: User) -> Void) {
        let facebookLogin = FBSDKLoginManager()
        
        // gets the name and user's friends
        facebookLogin.logInWithReadPermissions(["public_profile", "user_friends"], fromViewController: controller,handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                let alert = UIAlertController(title: "Facebook Login Failed",
                    message: facebookError.localizedDescription,
                    preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: "OK",
                    style: .Default) { (action: UIAlertAction) -> Void in
                }
                alert.addAction(cancelAction)
                controller.presentViewController(alert, animated: true, completion: nil)
            } else if facebookResult.isCancelled {
                // was cancelled, need this to do nothing
            } else {
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                FIRAuth.auth()?.signInWithCredential(credential) {
                    (user, error) in
                    if error != nil {
                        let alert = UIAlertController(title: "Login Failed",
                            message: error!.localizedDescription,
                            preferredStyle: .Alert)
                        
                        let cancelAction = UIAlertAction(title: "OK",
                            style: .Default) { (action: UIAlertAction) -> Void in
                        }
                        alert.addAction(cancelAction)
                        controller.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        // update user data on firebase
                        for profile in user!.providerData {
                            let myUser = User(name: profile.displayName!, id: user!.uid)
                            let userRef = FirebaseClient.Constants.USER_REF.child(user!.uid)
                            userRef.setValue(myUser.toAnyObject())
                            
                            // save user onto the phone
                            let prefs = NSUserDefaults.standardUserDefaults()
                            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(myUser)
                            prefs.setObject(encodedData, forKey: "user")
                            prefs.synchronize()
                            completionHandler(user: myUser)
                        }
                    }
                }
            }
        })
    }
    
    func searchForFriendsList(membersRef: FIRDatabaseReference, controller: UIViewController, completionHandler: (result: [Friend], error: NSError?) ->  Void) {
        let group = dispatch_group_create()
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields": "name, picture.type(large)"])
        
        graphRequest.startWithCompletionHandler({
            (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // shows error for internet connection failure
                let alert = UIAlertController(title: "Error",
                    message: "Search failed. \(error.localizedDescription)",
                    preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: "OK",
                    style: .Default) { (action: UIAlertAction) -> Void in
                        controller.navigationController?.popViewControllerAnimated(true)
                }
                alert.addAction(cancelAction)
                
                controller.presentViewController(alert, animated: true, completion: nil)
            } else if result["data"] as! NSArray == [] {
                completionHandler(result: [], error: error)
            }
            else
            {
                // get friend's id and profile picture
                var newFriends = [Friend]()
                for friend in result["data"] as! NSArray {
                    var profileImage: UIImage?
                    var id: String?
                    if let friendID = friend["id"] {
                        id = "facebook:" + (friendID as! String)
                    }
                    if let friendPicture = friend["picture"]! {
                        if let pictureData = friendPicture["data"]! {
                            let pictureURLString = pictureData["url"] as! String
                            let pictureURL = NSURL(string: pictureURLString)

                            if let image = NSData(contentsOfURL: pictureURL!) {
                                profileImage = UIImage(data: image)!
                            }
                        }
                    }
                    // enters a group so that I know when I finish executing firebase call
                    // checks if the id is a member of the group already
                    dispatch_group_enter(group)
                    self.isMember(membersRef, id: id!) {
                        isMember in
                        let friend = Friend(name: friend["name"] as! String, id: id!, image: profileImage, isMember: isMember)
                        newFriends.append(friend)
                        dispatch_group_leave(group)
                    }
                }
                // gets notified once firebase finishes call
                dispatch_group_notify(group, dispatch_get_main_queue()) {
                    completionHandler(result: newFriends, error: error)
                }
            }
        })
    }
    
    func isMember(membersRef: FIRDatabaseReference, id: String, completionHandler: (isMember: Bool) -> Void){
        membersRef.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            if snapshot.value![id] as? Bool == true {
                completionHandler(isMember: true)
            } else {
                completionHandler(isMember: false)
            }
        })
    }
    
    class func sharedInstance() -> FacebookClient {
        struct Singleton {
            static var sharedInstance = FacebookClient()
        }
        return Singleton.sharedInstance
    }
}