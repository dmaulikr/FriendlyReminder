//
//  UserEventViewController.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/30/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import CoreData

class UserEventViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()

        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
    }
    
    func initUI() {
        // init navbar
        navigationItem.title = "Personal"
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addUserEvent")
        let infoButton = UIButton(type: UIButtonType.InfoLight) as UIButton
        let leftBarButton = UIBarButtonItem()
        infoButton.frame = CGRectMake(0,0,30,30)
        infoButton.addTarget(self, action: "showInfo", forControlEvents: .TouchUpInside)
        leftBarButton.customView = infoButton
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = leftBarButton
        
        // init date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM d, y"
        let today = dateFormatter.stringFromDate(NSDate())
        dateLabel.text = today
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
        
        controller.groupEvent = false
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: - Core Data Convenience.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // MARK: - Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "UserEvent")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // reload tableView and save changes to core data
        tableView.reloadData()
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // MARK: - Configure Cell
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let event = fetchedResultsController.objectAtIndexPath(indexPath) as! UserEvent
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .LongStyle
        dateFormatter.dateFormat = "yyyyMMdd h:mm a"
        let oldDate = dateFormatter.dateFromString(event.date)
        dateFormatter.dateFormat = "MMMM d, y h:mm a"
        let dateString = dateFormatter.stringFromDate(oldDate!)
        
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = "Date of Event: " + dateString
    }
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "EventCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)! as UITableViewCell
        
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
                
                // delete object from fetchedResultsController
                sharedContext.deleteObject(userEvent)
            default:
                break
        }
    }
}
