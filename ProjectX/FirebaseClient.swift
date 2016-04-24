//
//  FirebaseClient.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/22/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import Firebase

class FirebaseClient {
    
    func getEvents(authID: String, completionHandler: (newEvents: [Event]) -> Void) {
        Constants.EVENT_REF.queryOrderedByChild("date").observeEventType(.Value, withBlock: { snapshot in
            var newEvents = [Event]()
            
            for event in snapshot.children {
                let event = Event(snapshot: event as! FDataSnapshot)
                if event.members[authID] as? Bool == true {
                    newEvents.append(event)
                }
            }
            completionHandler(newEvents: newEvents)
        })
    }
    
    func getTaskCounter(taskCounterRef: Firebase, userName: String, completionHandler: (taskCounter: Int) -> Void) {
        taskCounterRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let value = snapshot.value[userName] as! Int
            completionHandler(taskCounter: value)
        })
    }
    
    class func sharedInstance() -> FirebaseClient {
        struct Singleton {
            static var sharedInstance = FirebaseClient()
        }
        return Singleton.sharedInstance
    }
}