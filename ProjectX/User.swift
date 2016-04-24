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
    var id: String
    var ref: Firebase?
    
    init(name: String, id: String) {
        self.name = name
        self.id = id
        self.ref = nil
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