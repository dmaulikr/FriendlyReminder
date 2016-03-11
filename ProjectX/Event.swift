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
   // var tasks: [Task]?
    
    init(title: String, date: String) {
        self.title = title
        self.date = date
        self.ref = nil
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "title": title,
            "date": date
        ]
    }
    
    init(snapshot: FDataSnapshot) {
       // key = snapshot.key
        title = snapshot.value["title"] as! String
        date = snapshot.value["date"] as! String
        ref = snapshot.ref
    }
}
