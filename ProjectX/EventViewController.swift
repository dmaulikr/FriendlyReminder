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
    
    let ref = Firebase(url: "https://amber-inferno-4463.firebaseio.com/events/")
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
        ref.queryOrderedByChild("date").observeEventType(.Value, withBlock: { snapshot in
            
            var newEvents = [Event]()
            
            for event in snapshot.children {
                
                let event = Event(snapshot: event as! FDataSnapshot)
                
                // only append if user is part of event
                if event.members["userid"] as? String == self.authID {
                    newEvents.append(event)
                }
            }
            
            self.events = newEvents
            self.tableView.reloadData()
        })
        
        //print("\(data)")
    }
    
    
    func addEvent() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("EventCreatorViewController") as! EventCreatorViewController
        
        //controller.delegate = self
        controller.currentUserID = authID
        
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func logoutUser() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        let loginVC = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.presentViewController(loginVC, animated: true, completion: nil)
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let sectionInfo = self.fetchedResultsController.sections![section]
        //return sectionInfo.numberOfObjects
        return events.count
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

        //let cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        let event = events[indexPath.row]
        
        let controller = storyboard!.instantiateViewControllerWithIdentifier("TaskViewController") as! TaskViewController
        
        // need to pass reference to event title
        controller.ref = self.ref.childByAppendingPath("\(event.title.lowercaseString)" + "/tasks/")
        controller.userRef = Firebase(url: "https://amber-inferno-4463.firebaseio.com/users/\(authID!)/")

        self.navigationController!.pushViewController(controller, animated: true)
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

