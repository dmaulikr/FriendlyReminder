//
//  FacebookClient.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/16/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class FacebookClient {
    
    func login(controller: UIViewController, completionHandler: (authID: String) -> Void) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["public_profile","email", "user_friends"], fromViewController: controller,handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                FirebaseClient.Constants.BASE_REF.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in! \(authData)")
                            
                            // save user's authID onto the phone
                            let prefs = NSUserDefaults.standardUserDefaults()
                            prefs.setValue(authData.uid, forKey: "authID")
                            
                            // update user data on firebase
                            let user = User(name: authData.providerData["displayName"] as! String)
                            let userRef = FirebaseClient.Constants.USER_REF.childByAppendingPath(authData.uid)
                            
                            userRef.updateChildValues(["name": user.name, "userid": authData.uid])
                            
                            completionHandler(authID: authData.uid)
                        }
                })
            }
        })
    }
    
    func searchForFriendsList(membersRef: Firebase, completionHandler: (result: [Friend], picture: UIImage?, error: NSError?) ->  Void) {
 
        let group = dispatch_group_create()

        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields": "name, picture.type(large)"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            var profileImage: UIImage?
            var id: String?
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                // returns friend array
                //print(result)
                //print(result["picture"])
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
        membersRef.observeEventType(.Value, withBlock: {
            snapshot in
            if snapshot.value[id]! != nil {
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