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
    
    init(title: String, creator: String) {
        self.title = title
        self.ref = nil
        self.creator = creator
    }
    
    init(snapshot: FDataSnapshot) {
        title = snapshot.value["title"] as! String
        ref = snapshot.ref
        creator = snapshot.value["creator"] as! String
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "title": title,
            "creator": creator
        ]
    }
}