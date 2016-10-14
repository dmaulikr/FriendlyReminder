//
//  EventCreatorViewController.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 2/26/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class EventCreatorViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var eventTitle: UITextField!
    
    var user: User!
    var groupEvent: Bool!
    var tapRecognizer: UITapGestureRecognizer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventTitle.delegate = self
        eventTitle.becomeFirstResponder()
        
        // set minimum date to today (can't go back in time)
        let date = Date()
        datePicker.minimumDate = date
        configureTapRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardDismissRecognizer()
    }
    
    // MARK: - TextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        eventTitle.resignFirstResponder()
        return true
    }
    
    // MARK: - Buttons

    @IBAction func cancelEvent(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // creates an event
    @IBAction func createEvent(_ sender: AnyObject) {
        // Throw alert if title is empty
        if eventTitle.text == "" {
            Alerts.sharedInstance().createAlert("Event title",
                message: "Event title can't be empty!", VC: self, withReturn: false)
            return
        }
        
        let date = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .long
        dateFormatter.dateFormat = "yyyyMMdd h:mm a"
        let dateString = dateFormatter.string(from: date)
        
        if groupEvent == true {
            // save to Firebase
            let event = Event(title: eventTitle.text!, date: dateString, members: [user.id: true], taskCounter: [user.name: 0], creator: user.name)
            let eventRef = FirebaseClient.Constants.EVENT_REF.child(eventTitle.text!.lowercased() + "/")
            eventRef.observeSingleEvent(of: .value, with: {
                snapshot in
                if snapshot.exists() {
                    Alerts.sharedInstance().createAlert("Event title taken",
                        message: "Please use a different event title.", VC: self, withReturn: false)
                } else {
                    eventRef.setValue(event.toAnyObject())
                    self.dismiss(animated: true, completion: nil)
                }
            })
        } else {
            // create UserEvent, gets saved in UserEventViewController (on insert)
            let _ = UserEvent(title: eventTitle.text!, date: dateString, context: self.sharedContext)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Core Data Convenience.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // MARK: - Keyboard Tap Recognizer
    
    func configureTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    func addKeyboardDismissRecognizer() {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}




