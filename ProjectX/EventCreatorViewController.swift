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
    
    let ref = Firebase(url: "https://amber-inferno-4463.firebaseio.com/events/")

    
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
        // TODO: Create an Alert if title is nil
        
        // save to Firebase
        let date = datePicker.date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.stringFromDate(date)
        
        let event = Event(title: eventTitle.text!, date: dateString)
        
        let eventItemRef = self.ref.childByAppendingPath(eventTitle.text!.lowercaseString)
/*
        let myDict = [
            "title": event.title,
            "date": event.date
        ]
*/
      //  eventItemRef.setValue(myDict)
        eventItemRef.setValue(event.toAnyObject())
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}



