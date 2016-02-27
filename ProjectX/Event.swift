//
//  Event.swift
//  ProjectX
//
//  Created by Jonathan Chou on 2/26/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import CoreData

class Event : NSManagedObject {
    
    struct Keys {
        static let Title = "title"
    }
    
    @NSManaged var title: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {

        let entity =  NSEntityDescription.entityForName("Event", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)

        title = dictionary[Keys.Title] as! String
    }
}
