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
    var image: UIImage?
    // var tasks: [Task]?
    
    init(name: String, image: UIImage?) {
        self.name = name
        self.image = image
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "name": name,
        ]
    }
    
    init(snapshot: FDataSnapshot) {
        // key = snapshot.key
        name = snapshot.value["name"] as! String
    }
}