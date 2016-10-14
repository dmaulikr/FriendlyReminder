//
//  UserTask.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 4/1/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import CoreData

class UserTask: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var created: String
    @NSManaged var isDone: Bool
    @NSManaged var event: UserEvent
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(title: String, created: String, event: UserEvent, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entity(forEntityName: "UserTask", in: context)!
        super.init(entity: entity,insertInto: context)
        self.title = title
        self.created = created
        self.event = event
        self.isDone = false
    }
}

