//
//  Friend.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/17/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import Foundation
import Firebase

class Friend {
    var name: String
    var id: String
    var image: UIImage?
    var isMember: Bool
    // var tasks: [Task]?
    
    init(name: String, id: String, image: UIImage?, isMember: Bool) {
        self.name = name
        self.id = id
        self.image = image
        self.isMember = isMember
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "name": name,
        ]
    }
    /*
    init(snapshot: FDataSnapshot) {
        // key = snapshot.key
        name = snapshot.value["name"] as! String
        
    }
*/
}