//
//  Task.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/10/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import Firebase

class Task {
    var title: String
    var ref: Firebase?
    var creator: String
    var inCharge: [String]
    
    init(title: String, creator: String, ref: Firebase) {
        self.title = title
        self.ref = ref
        self.creator = creator
        self.inCharge = ["no one"]
    }
    
    init(snapshot: FDataSnapshot) {
        title = snapshot.value["title"] as! String
        ref = snapshot.ref
        creator = snapshot.value["creator"] as! String
        inCharge = snapshot.value["inCharge"] as! [String]
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "title": title,
            "creator": creator,
            "inCharge": inCharge
        ]
    }
}