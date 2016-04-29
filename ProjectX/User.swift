//
//  User.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 3/14/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import Firebase

class User: NSObject, NSCoding {
    var name: String
    var id: String
    var ref: Firebase?
    
    init(name: String, id: String) {
        self.name = name
        self.id = id
        self.ref = nil
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey("name") as! String
        let id = aDecoder.decodeObjectForKey("id") as! String
        self.init(name: name, id: id)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(name, forKey: "name")
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "name": name,
            "id": id
        ]
    }
    
    init(snapshot: FDataSnapshot) {
        name = snapshot.value["name"] as! String
        id = snapshot.value["id"] as! String
        ref = snapshot.ref
    }
}