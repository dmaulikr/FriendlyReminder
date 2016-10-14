//
//  FirebaseClient.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 3/22/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import Firebase

class FirebaseClient {
    
    func getEvents(_ authID: String, completionHandler: @escaping (_ newEvents: [Event]) -> Void) {
        Constants.EVENT_REF.queryOrdered(byChild: "date").observe(.value, with: {
            snapshot in
            var newEvents = [Event]()
            
            for event in snapshot.children {
                let event = Event(snapshot: event as! FIRDataSnapshot)
                if event.members[authID] as? Bool == true {
                    newEvents.append(event)
                }
            }
            completionHandler(newEvents)
        })
    }
    
    func getTaskCounter(_ taskCounterRef: FIRDatabaseReference, userName: String, completionHandler: @escaping (_ taskCounter: Int) -> Void) {
        taskCounterRef.observeSingleEvent(of: .value, with: {
            snapshot in
            //let value = snapshot.value![userName] as! Int
            let value = (snapshot.value as? NSDictionary)?[userName] as? Int ?? 0
            completionHandler(value)
        })
    }
    
    // initializes the user's presence
    func createPresence(_ myConnectionsRef: FIRDatabaseReference, completionHandler: @escaping () -> Void) {
        let group = DispatchGroup()
        group.enter()

        Constants.CONNECT_REF.observe(.value, with: {
            snapshot in
            let connected = snapshot.value as? Bool
            if connected != nil && connected! {
                // connection established (or I've reconnected after a loss of connection)
                // add this device to my connections list
                let con = myConnectionsRef.childByAutoId()
                con.setValue("YES")
                // when this device disconnects, remove it
                con.onDisconnectRemoveValue()
                group.leave()
            }
        })
        
        group.notify(queue: DispatchQueue.main) {
            completionHandler()
        }
    }
    
    // checks to see if the user is connected
    func checkPresence(_ completionHandler: @escaping (_ connected: Bool) -> Void) {
        Constants.CONNECT_REF.observe(.value, with: {
            snapshot in
            let connected = snapshot.value as? Bool
            if connected != nil && connected! {
                completionHandler(true)
            } else {
                completionHandler(false)
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
