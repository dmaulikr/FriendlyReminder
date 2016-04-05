//
//  UserEvent.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/24/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import CoreData

class UserEvent: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var date: String
    @NSManaged var tasks: [UserTask]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(title: String, date: String, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("UserEvent", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.title = title
        self.date = date
    }

}
