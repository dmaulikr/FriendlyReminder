//
//  Event.swift
//  ProjectX
//
//  Created by Jonathan Chou on 2/26/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import CoreData

class Event : NSManagedObject {
 /*
    struct Keys {
        static let Title = "title"
        static let Date = "date"
    }
 */
    @NSManaged var title: String
    @NSManaged var date: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(title: String, date: String, context: NSManagedObjectContext) {

        let entity =  NSEntityDescription.entityForName("Event", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)

        self.title = title
        self.date = date
    }
    
    func toAnyObject() -> AnyObject {
        return [ "title": title as String, "date": date as String ]
    }
}
