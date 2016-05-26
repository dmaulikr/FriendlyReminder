//
//  FirebaseConstants.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 3/22/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import Firebase

extension FirebaseClient {
    
    struct Constants {
        static let BASE_REF = FIRDatabase.database().reference()
        static let EVENT_REF = BASE_REF.child("events/")
        static let USER_REF = BASE_REF.child("users/")
        static let CONNECT_REF = BASE_REF.child(".info/connected/")
    }
}
