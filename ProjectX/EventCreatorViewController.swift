//
//  EventCreatorViewController.swift
//  ProjectX
//
//  Created by Jonathan Chou on 2/26/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import Firebase

class EventCreatorViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var eventTitle: UITextField!
    
    let ref = Firebase(url: "https://amber-inferno-4463.firebaseio.com/")
    var currentUserID: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set minimum date to today (can't go back in time)
        let date = NSDate()
        datePicker.minimumDate = date
    }
    
    

    @IBAction func cancelEvent(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func createEvent(sender: AnyObject) {
        // Throw alert if title is nil
        if eventTitle.text == "" {
            let alert = UIAlertController(title: "Event title",
                message: "Event title can't be empty!",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                style: .Default) { (action: UIAlertAction) -> Void in
            }
            alert.addAction(cancelAction)
            
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        // save to Firebase
        let date = datePicker.date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.stringFromDate(date)
        
        let event = Event(title: eventTitle.text!, date: dateString, members: ["userid": currentUserID!])
        
        // set event
        let eventRef = self.ref.childByAppendingPath("events/" + eventTitle.text!.lowercaseString + "/")
        eventRef.setValue(event.toAnyObject())
        
        // update user
        let userRef = self.ref.childByAppendingPath("users/" + currentUserID! + "/events/")
        userRef.updateChildValues([event.title: true])

        self.dismissViewControllerAnimated(true, completion: nil)
    }
}



