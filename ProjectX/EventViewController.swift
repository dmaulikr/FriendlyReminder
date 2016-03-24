//
//  EventViewController.swift
//  ProjectX
//
//  Created by Jonathan Chou on 2/24/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FBSDKLoginKit

class EventViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var events = [Event]()
    var authID: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Events"
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addEvent")
        navigationItem.rightBarButtonItems = [self.editButtonItem(), addButton]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutUser")

 /*
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
*/
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
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func logoutUser() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
        /*
        let loginVC = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.presentViewController(loginVC, animated: true, completion: nil)
*/
    }
/*
    // MARK: - Core Data Convenience.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // Step 1 - Add the lazy fetchedResultsController property. See the reference sheet in the lesson if you
    // want additional help creating this property.
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Event")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
*/
    // MARK: - Table View
    
    // one for group todos and one for personal todos
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let sectionInfo = self.fetchedResultsController.sections![section]
        //return sectionInfo.numberOfObjects
        if section == 0 {
            return events.count
        } else {
            //let sectionInfo = self.fetchedResultsController.sections![section]
            //return sectionInfo.numberOfObjects
            return 0
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "EventCell"
        // Here is how to replace the actors array using objectAtIndexPath
        let event = events[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)! as UITableViewCell//as! TaskCancelingTableViewCell
        
        // This is the new configureCell method
        configureCell(cell, event: event)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.section == 0 {
            let event = events[indexPath.row]
            let controller = storyboard!.instantiateViewControllerWithIdentifier("TaskViewController") as! TaskViewController
            
            // need to pass reference to event title
            controller.ref = FirebaseClient.Constants.EVENT_REF.childByAppendingPath("\(event.title.lowercaseString)" + "/tasks/")
            controller.userRef = FirebaseClient.Constants.USER_REF.childByAppendingPath("\(authID!)/")
            
            self.navigationController!.pushViewController(controller, animated: true)
        } else {
            // core data -- personal array
        }

    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("EventCell")! as UITableViewCell
        headerCell.backgroundColor = UIColor.cyanColor()
        //headerCell.textLabel?.textAlignment = .Center
        
        if section == 0 {
            headerCell.textLabel?.text = "Group";
        } else {
            headerCell.textLabel?.text = "Personal";
        }
        
        return headerCell
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
    
    func configureCell(cell: UITableViewCell, event: Event) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let oldDate = dateFormatter.dateFromString(event.date)
        dateFormatter.dateFormat = "MMMM d, y"
        let dateString = dateFormatter.stringFromDate(oldDate!)
        
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = "Deadline: " + dateString
        //cell.detailTextLabel?.text = self.data?.providerData["displayName"] as? String
    }

}

