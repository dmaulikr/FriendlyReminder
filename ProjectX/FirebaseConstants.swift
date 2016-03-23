//
//  FirebaseConstants.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/22/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import Firebase

extension FirebaseClient {
    
    struct Constants {
        static let BASE_REF = Firebase(url: "https://amber-inferno-4463.firebaseio.com/")
        static let EVENT_REF = Firebase(url: "https://amber-inferno-4463.firebaseio.com/events/")
        static let USER_REF = Firebase(url: "https://amber-inferno-4463.firebaseio.com/users/")
    }
    
}
