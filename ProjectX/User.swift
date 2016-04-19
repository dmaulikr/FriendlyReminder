//
//  User.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/14/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import Firebase

class User {
    var name: String
    var events: NSDictionary?
    var ref: Firebase?
    
    init(name: String) {
        self.name = name
        self.events = nil
        self.ref = nil
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "name": name,
            "events": events!
        ]
    }
    
    init(snapshot: FDataSnapshot) {
        name = snapshot.value["name"] as! String
        events = snapshot.value["events"] as? NSDictionary
        ref = snapshot.ref
    }
}