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

class FacebookClient {
    
    func searchForFriendsList(completionHandler: (result: NSArray, error: NSError?) ->  Void) {

        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields": "name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                // goes through friend array and gets names
                completionHandler(result: result["data"] as! NSArray, error: error)
                /*
                for friend in (result["data"] as! NSArray) {
                    print(friend["name"] as! String)
                }
*/
                //let name = (result.valueForKey("data")?.valueForKey("first_name") as! String) + " "// + //(result.valueForKey("data")?.valueForKey("last_name") as! String)
                //print(name)
               // let userName : NSString = result.valueForKey("name") as! NSString
                //print("User Name is: \(userName)")
                //print(result["data"])

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