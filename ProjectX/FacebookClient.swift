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
    
    enum InputError: Error {
        
    }
    
    func login(_ controller: UIViewController, completionHandler: @escaping (_ user: User) -> Void) {
        let facebookLogin = FBSDKLoginManager()
        
        // gets the name and user's friends
        facebookLogin.logIn(withReadPermissions: ["public_profile", "user_friends"], from: controller,handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                Alerts.sharedInstance().createAlert("Facebook Login Failed",
                    message: (facebookError?.localizedDescription)!, VC: controller, withReturn: false)
            } else if (facebookResult?.isCancelled)! {
                // was cancelled, need this to do nothing
            } else {
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                FIRAuth.auth()?.signIn(with: credential) {
                    (user, error) in
                    if error != nil {
                        Alerts.sharedInstance().createAlert("Login Failed",
                            message: error!.localizedDescription, VC: controller, withReturn: false)
                    } else {
                        // update user data on firebase
                        for profile in user!.providerData {
                            let myUser = User(name: profile.displayName!, id: user!.uid)
                            let userRef = FirebaseClient.Constants.USER_REF.child(user!.uid)
                            userRef.setValue(myUser.toAnyObject())
                            
                            // save user onto the phone
                            let prefs = UserDefaults.standard
                            let encodedData = NSKeyedArchiver.archivedData(withRootObject: myUser)
                            prefs.set(encodedData, forKey: "user")
                            prefs.synchronize()
                            completionHandler(myUser)
                        }
                    }
                }
            }
        })
    }
    
    func searchForFriendsList(_ membersRef: FIRDatabaseReference, controller: UIViewController, completionHandler: @escaping (_ result: [Friend], _ error: NSError?) ->  Void) {
        let group = DispatchGroup()
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields": "name, picture.type(large)"])
        
        graphRequest.start(completionHandler: {
            (connection, result, error) -> Void in
            let dict = result as? NSDictionary

            if ((error) != nil)
            {
                // shows error for internet connection failure
                Alerts.sharedInstance().createAlert("Error",
                    message: "Search failed.", VC: controller, withReturn: true)
            } else if dict?["data"] as! NSArray == [] {
                completionHandler([], error as NSError?)
            }
            else
            {
                // get friend's id and profile picture
                var newFriends = [Friend]()
                for friend in dict?["data"] as! [[String: AnyObject]] {
                    var profileImage: UIImage?
                    var id: String?
                    if let friendID = friend["id"] {
                        id = "facebook:" + (friendID as! String)
                    }
                    if let friendPicture = friend["picture"] as? NSDictionary {
                        if let pictureData = friendPicture["data"] as? NSDictionary {
                            let pictureURLString = pictureData["url"] as! String
                            let pictureURL = URL(string: pictureURLString)

                            if let image = try? Data(contentsOf: pictureURL!) {
                                profileImage = UIImage(data: image)!
                            }
                        }
                    }
                    // enters a group so that I know when I finish executing firebase call
                    // checks if the id is a member of the group already
                    group.enter()
                    self.isMember(membersRef, id: id!) {
                        isMember in
                        let friend = Friend(name: friend["name"] as! String, id: id!, image: profileImage, isMember: isMember)
                        newFriends.append(friend)
                        group.leave()
                    }
                }
                // gets notified once firebase finishes call
                group.notify(queue: DispatchQueue.main) {
                    completionHandler(newFriends, error as NSError?)
                }
            }
        })
    }
    
    func isMember(_ membersRef: FIRDatabaseReference, id: String, completionHandler: @escaping (_ isMember: Bool) -> Void){
        membersRef.observeSingleEvent(of: .value, with: {
            snapshot in
            let dict = snapshot.value as? NSDictionary

            if dict?[id] as? Bool == true {
                completionHandler(true)
            } else {
                completionHandler(false)
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
