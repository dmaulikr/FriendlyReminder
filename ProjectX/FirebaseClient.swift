//
//  FirebaseClient.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 3/22/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import Firebase

class FirebaseClient {
    
    func getEvents(authID: String, completionHandler: (newEvents: [Event]) -> Void) {
        Constants.EVENT_REF.queryOrderedByChild("date").observeEventType(.Value, withBlock: {
            snapshot in
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
        taskCounterRef.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            let value = snapshot.value[userName] as! Int
            completionHandler(taskCounter: value)
        })
    }
    
    // initializes the user's presence
    func createPresence(myConnectionsRef: Firebase) {
        Constants.CONNECT_REF.observeEventType(.Value, withBlock: {
            snapshot in
            let connected = snapshot.value as? Bool
            if connected != nil && connected! {
                // connection established (or I've reconnected after a loss of connection)
                // add this device to my connections list
                let con = myConnectionsRef.childByAutoId()
                con.setValue("YES")
                // when this device disconnects, remove it
                con.onDisconnectRemoveValue()
            }
        })
    }
    
    // checks to see if the user is connected
    func checkPresence(completionHandler: (connected: Bool) -> Void) {
        Constants.CONNECT_REF.observeEventType(.Value, withBlock: {
            snapshot in
            let connected = snapshot.value as? Bool
            if connected != nil && connected! {
                completionHandler(connected: true)
            } else {
                completionHandler(connected: false)
            }
        })
    }
    
    class func sharedInstance() -> FirebaseClient {
        struct Singleton {
            static var sharedInstance = FirebaseClient()
        }
        return Singleton.sharedInstance
    }
}