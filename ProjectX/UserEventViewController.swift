//
//  UserEventViewController.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/30/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FBSDKLoginKit

class UserEventViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var authID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavBar()

        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func initNavBar() {
        navigationItem.title = "User Events"
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addUserEvent")
        let infoButton = UIButton(type: UIButtonType.InfoLight) as UIButton
        let leftBarButton = UIBarButtonItem()
        infoButton.frame = CGRectMake(0,0,30,30)
        infoButton.addTarget(self, action: "showInfo", forControlEvents: .TouchUpInside)
        leftBarButton.customView = infoButton
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func showInfo() {
        let alert = UIAlertController(title: "Instructions",
            message: "Swipe left to delete",
            preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "OK",
            style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func addUserEvent() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("EventCreatorViewController") as! EventCreatorViewController
        
        controller.authID = authID
        controller.groupEvent = false
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func logoutUser() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Core Data Convenience.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // Step 1 - Add the lazy fetchedResultsController property. See the reference sheet in the lesson if you
    // want additional help creating this property.
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "UserEvent")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - Fetched Results Controller Delegate - Need to have this or else NSFetchedResultsController won't update
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            print("insert")
            tableView.reloadData()
            break
        case .Delete:
            print("delete")
            tableView.reloadData()
            break
        default:
            break
        }
    }
    
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "EventCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)! as UITableViewCell//as! TaskCancelingTableViewCell
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("UserTaskViewController") as! UserTaskViewController
        
        controller.userEvent = fetchedResultsController.objectAtIndexPath(indexPath) as! UserEvent
        
        self.navigationController!.pushViewController(controller, animated: true)
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            switch (editingStyle) {
            case .Delete:
                let userEvent = fetchedResultsController.objectAtIndexPath(indexPath) as! UserEvent
                
                // iterate through fetchedResultsController to find the event then delete it
                sharedContext.deleteObject(userEvent)
                CoreDataStackManager.sharedInstance().saveContext()
                break
            default:
                break
            }
    }
    
    // MARK: - Configure Cell
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let event = fetchedResultsController.objectAtIndexPath(indexPath) as! UserEvent
 
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let oldDate = dateFormatter.dateFromString(event.date)
        dateFormatter.dateFormat = "MMMM d, y"
        let dateString = dateFormatter.stringFromDate(oldDate!)
        
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = "Date of Event: " + dateString
    }
    
}