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
    var ref: FIRDatabaseReference?
    
    init(name: String, id: String) {
        self.name = name
        self.id = id
        self.ref = nil
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let id = aDecoder.decodeObject(forKey: "id") as! String
        self.init(name: name, id: id)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "id": id
        ]
    }
    
    init(snapshot: FIRDataSnapshot) {
        let dict = snapshot.value as? NSDictionary
        name = dict?["name"] as! String
        id = dict?["id"] as! String
        
 //       name = snapshot.value!["name"] as! String
 //       id = snapshot.value!["id"] as! String
        ref = snapshot.ref
    }
}
