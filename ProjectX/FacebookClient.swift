//
//  FacebookClient.swift
//  ProjectX
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
                print("Facebook login failed. Error \(facebookError)")
                // dont need alerts here because safari notifies user
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                FirebaseClient.Constants.BASE_REF.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            
                            // update user data on firebase
                            let user = User(name: authData.providerData["displayName"] as! String, id: authData.uid)
                            let userRef = FirebaseClient.Constants.USER_REF.childByAppendingPath(authData.uid)
                            userRef.setValue(user.toAnyObject())
                            
                            // save user onto the phone
                            let prefs = NSUserDefaults.standardUserDefaults()
                            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(user)
                            prefs.setObject(encodedData, forKey: "user")
                            prefs.synchronize()
                            
                            completionHandler(user: user)
                        }
                })
            }
        })
    }
    
    func searchForFriendsList(membersRef: Firebase, controller: UIViewController, completionHandler: (result: [Friend], picture: UIImage?, error: NSError?) ->  Void) {
 
        let group = dispatch_group_create()

        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields": "name, picture.type(large)"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            var profileImage: UIImage?
            var id: String?
            if ((error) != nil)
            {
                // Process error
                // prints error for internet connection failure
                let alert = UIAlertController(title: "Error",
                    message: "Search failed. \(error.localizedDescription)",
                    preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: "OK",
                    style: .Default) { (action: UIAlertAction) -> Void in
                        controller.navigationController?.popViewControllerAnimated(true)
                }
                alert.addAction(cancelAction)
                
                controller.presentViewController(alert, animated: true, completion: nil)
            }
            else
            {
                // get friend's id and profile picture
                var newFriends = [Friend]()
                for friend in result["data"] as! NSArray {
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
                    // gets notified once firebase finishes call
                    dispatch_group_notify(group, dispatch_get_main_queue()) {
                        completionHandler(result: newFriends, picture: profileImage, error: error)
                    }
                }
            }
        })
        
    }
    
    func isMember(membersRef: Firebase, id: String, completionHandler: (isMember: Bool) -> Void){
        membersRef.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            if snapshot.value[id] as? Bool == true {
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