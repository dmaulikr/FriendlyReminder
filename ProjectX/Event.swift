//
//  Event.swift
//  ProjectX
//
//  Created by Jonathan Chou on 2/26/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import CoreData
import Firebase

class Event {
    var title: String
    var date: String
    var ref: Firebase?
    var members: NSDictionary
   // var tasks: [Task]?
    
    init(title: String, date: String, members: NSDictionary) {
        self.title = title
        self.date = date
        self.ref = nil
        self.members = members
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "title": title,
            "date": date,
            "members": members
        ]
    }
    
    init(snapshot: FDataSnapshot) {
       // key = snapshot.key
        title = snapshot.value["title"] as! String
        date = snapshot.value["date"] as! String
        ref = snapshot.ref
        members = snapshot.value["members"] as! NSDictionary
    }
}
