//
//  UserTask.swift
//  ProjectX
//
//  Created by Jonathan Chou on 4/1/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//
import CoreData

class UserTask: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var created: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(title: String, created: String, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("UserTask", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        self.title = title
        self.created = created
    }
}

