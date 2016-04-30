//
//  Friend.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 3/17/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import Firebase

class Friend {
    var name: String
    var id: String
    var image: UIImage?
    var isMember: Bool
    
    init(name: String, id: String, image: UIImage?, isMember: Bool) {
        self.name = name
        self.id = id
        self.image = image
        self.isMember = isMember
    }
}