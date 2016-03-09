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

class EventViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    let ref = Firebase(url: "https://https://amber-inferno-4463.firebaseio.com/grocery-items")

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = self.editButtonItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addEvent")
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
    }
    
    
    func addEvent() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("EventCreatorViewController") as! EventCreatorViewController
        
        //controller.delegate = self
        
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
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
    
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "EventCell"
        
        // Here is how to replace the actors array using objectAtIndexPath
        let event = fetchedResultsController.objectAtIndexPath(indexPath) as! Event
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)! as UITableViewCell//as! TaskCancelingTableViewCell
        
        // This is the new configureCell method
        configureCell(cell, event: event)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            switch (editingStyle) {
            case .Delete: break
                /*
                // Here we get the actor, then delete it from core data
                let movie = fetchedResultsController.objectAtIndexPath(indexPath) as! Movie
                sharedContext.deleteObject(movie)
                CoreDataStackManager.sharedInstance().saveContext()
                */
            default:
                break
            }
    }
    
    // MARK: - Configure Cell
    
    func configureCell(cell: UITableViewCell, event: Event) {
        
    }

}

