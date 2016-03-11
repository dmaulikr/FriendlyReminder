//
//  Task.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/10/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import CoreData
import Firebase

class Task {
    var title: String
    var ref: Firebase?
    
    init(title: String) {
        self.title = title
        self.ref = nil
    }
    
    init(snapshot: FDataSnapshot) {
        title = snapshot.value["title"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "title": title
        ]
    }
}