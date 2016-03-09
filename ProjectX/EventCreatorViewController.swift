//
//  EventCreatorViewController.swift
//  ProjectX
//
//  Created by Jonathan Chou on 2/26/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import CoreData

class EventCreatorViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var eventTitle: UITextField!
    
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
        
    }
}
