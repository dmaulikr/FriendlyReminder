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
    var authID: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Group Events"
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addEvent")
        navigationItem.rightBarButtonItems = [addButton]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutUser")

    }
    
    // reloads the tableview data and event array
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        
        // get this user's events that the user is a part of
        FirebaseClient.sharedInstance().getEvents(authID!) {
            (newEvents) -> Void in
            self.events = newEvents
            self.tableView.reloadData()
        }
        
    }
    
    
    func addEvent() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("EventCreatorViewController") as! EventCreatorViewController
        
        controller.authID = authID
        controller.groupEvent = true
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func logoutUser() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
  

    // MARK: - Table View
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "EventCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)! as UITableViewCell//as! TaskCancelingTableViewCell
        
        configureCell(cell, indexPath: indexPath)

        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event = events[indexPath.row]
        let controller = storyboard!.instantiateViewControllerWithIdentifier("TaskViewController") as! TaskViewController
        
        // need to pass reference to event title
        controller.ref = FirebaseClient.Constants.EVENT_REF.childByAppendingPath("\(event.title.lowercaseString)" + "/tasks/")
        controller.eventRef = FirebaseClient.Constants.EVENT_REF.childByAppendingPath("\(event.title.lowercaseString)" + "/")
        controller.userRef = FirebaseClient.Constants.USER_REF.childByAppendingPath("\(authID!)/")
        controller.eventTitle = event.title
        
        self.navigationController!.pushViewController(controller, animated: true)

    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        // no one can edit for now
        // TODO: make it so only the creator can delete the event... and tasks?
        return UITableViewCellEditingStyle.None

    }
    
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
    
    // MARK: - Configure Cell
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let event = events[indexPath.row]

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let oldDate = dateFormatter.dateFromString(event.date)
        dateFormatter.dateFormat = "MMMM d, y"
        let dateString = dateFormatter.stringFromDate(oldDate!)
        
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = "Date of Event: " + dateString
        //cell.detailTextLabel?.text = self.data?.providerData["displayName"] as? String
    }

}

