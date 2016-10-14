//
//  Task.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 3/10/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import Firebase

class Task {
    var title: String
    var ref: FIRDatabaseReference?
    var creator: String
    var inCharge: [String]?
    var complete: Bool
    
    init(title: String, creator: String, ref: FIRDatabaseReference) {
        self.title = title
        self.ref = ref
        self.creator = creator
        self.inCharge = []
        self.complete = false
    }
    
    init(snapshot: FIRDataSnapshot) {
        let dict = snapshot.value as? NSDictionary
        title = dict?["title"] as! String
        creator = dict?["creator"] as! String
        inCharge = dict?["inCharge"] as? [String]
        complete = dict?["complete"] as! Bool
   //     title = snapshot.value!["title"] as! String
        ref = snapshot.ref
   //     creator = snapshot.value!["creator"] as! String
   //     inCharge = snapshot.value!["inCharge"] as? [String]
   //     complete = snapshot.value!["complete"] as! Bool
    }
    
    func toAnyObject() -> Any {
        return [
            "title": title,
            "creator": creator,
            "complete": complete
        ]
    }
}
