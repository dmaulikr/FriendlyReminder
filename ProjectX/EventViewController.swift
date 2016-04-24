//
//  EventViewController.swift
//  ProjectX
//
//  Created by Jonathan Chou on 2/24/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class EventViewController: UITableViewController {
    
    var events = [Event]()
    var user: User!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var activityView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // get current user's events
        FirebaseClient.sharedInstance().getEvents(user.id) {
            (newEvents) -> Void in
            self.events = newEvents
            self.tableView.reloadData()
            self.activityView.hidden = true
        }
    }
    
    // initializes UI elements
    func initUI() {
        // initialize navbar
        navigationItem.title = "Group Events"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addEvent")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutUser")
        
        // initialize today's date in dateLabel
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM d, y"
        let today = dateFormatter.stringFromDate(NSDate())
        dateLabel.text = today
    }
    
    // goes to the view controller made to create events
    func addEvent() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("EventCreatorViewController") as! EventCreatorViewController
        
        controller.user = user
        controller.groupEvent = true
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // logs out the user
    func logoutUser() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        FirebaseClient.Constants.BASE_REF.unauth()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Configure Cell
    
    // configures cell
    func configureCell(cell: EventCell, indexPath: NSIndexPath) {
        let event = events[indexPath.row]
        
        // changes the date format
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .LongStyle
        dateFormatter.dateFormat = "yyyyMMdd h:mm a"
        let oldDate = dateFormatter.dateFromString(event.date)
        dateFormatter.dateFormat = "MMMM d, y h:mm a"
        let dateString = dateFormatter.stringFromDate(oldDate!)
        
        cell.title.text = event.title
        cell.dateOfEvent.text = "Date of Event: " + dateString
        cell.tasksLeft.text = String(event.taskCounter.valueForKey(user.name)!)
    }
  

    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "EventCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! EventCell
        
        configureCell(cell, indexPath: indexPath)

        return cell
    }
    
    // goes to task view controller when user selects an event
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event = events[indexPath.row]
        let controller = storyboard!.instantiateViewControllerWithIdentifier("TaskViewController") as! TaskViewController
        
        // need to pass reference to event title
        controller.user = user
        controller.event = event
        controller.ref = event.ref!.childByAppendingPath("tasks")
        controller.taskCounterRef = event.ref!.childByAppendingPath("taskCounter")

        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        let event = events[indexPath.row]
        if event.creator == user.name {
            return UITableViewCellEditingStyle.Delete
        } else {
            return UITableViewCellEditingStyle.None
        }
    }
    
    // TODO: add delete capabilities for creator of events
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            switch (editingStyle) {
            case .Delete:
                let event = events[indexPath.row]
                event.ref?.removeValue()
            default:
                break
            }
    }


}

