//
//  UserTaskViewController.swift
//  ProjectX
//
//  Created by Jonathan Chou on 4/1/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import CoreData

class UserTaskViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var userEvent: UserEvent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = userEvent.title
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTask")
        
        navigationItem.rightBarButtonItems = [addButton]
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
    }
    
    // reloads the tableview data and task array
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func addTask() {
        // alert to add task
        
        // Alert View for input
        let alert = UIAlertController(title: "Task creation",
            message: "Add a task",
            preferredStyle: .Alert)
        
        let createAction = UIAlertAction(title: "Create",
            style: .Default) { (action: UIAlertAction) -> Void in
                
                if alert.textFields![0].text == "" {
                    let alert2 = UIAlertController(title: "Task title",
                        message: "Task title can't be empty!",
                        preferredStyle: .Alert)
                    
                    let cancelAction = UIAlertAction(title: "OK",
                        style: .Default) { (action: UIAlertAction) -> Void in
                    }
                    alert2.addAction(cancelAction)
                    
                    self.presentViewController(alert2, animated: true, completion: nil)
                    return
                }
                let textField = alert.textFields![0]
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let createdAt = dateFormatter.stringFromDate(NSDate())
                // create a UserTask into CoreData
                let _ = UserTask(title: textField.text!, created: createdAt, event: self.userEvent,
                                 context: self.sharedContext)
                CoreDataStackManager.sharedInstance().saveContext()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        
        // fixes collection view error
        alert.view.setNeedsLayout()
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Core Data Convenience.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "UserTask")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "event == %@", self.userEvent)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - Fetched Results Controller Delegate
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            print("insert")
            
        case .Delete:
            print("delete")

            
        case .Update:
            print("update")
            let cell = tableView.cellForRowAtIndexPath(indexPath!)!
            let task = controller.objectAtIndexPath(indexPath!) as! UserTask
            toggleCellCheckbox(cell, completed: task.isDone)
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // need to reload tableView and save changes to core data
        tableView.reloadData()
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "UserTaskCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)! as UITableViewCell
        
        // This is the new configureCell method
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let userTask = fetchedResultsController.objectAtIndexPath(indexPath) as! UserTask
        let completed = userTask.isDone
        userTask.isDone = !completed

    }
    

    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            switch (editingStyle) {
            case .Delete:
                let userTask = fetchedResultsController.objectAtIndexPath(indexPath) as! UserTask
                
                // iterate through fetchedResultsController to find the task then delete it
                sharedContext.deleteObject(userTask)
           //     CoreDataStackManager.sharedInstance().saveContext()
                break
            default:
                break
            }
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let task = fetchedResultsController.objectAtIndexPath(indexPath) as! UserTask
        
        cell.textLabel?.text = task.title
        toggleCellCheckbox(cell, completed: task.isDone)
    }
    
    func toggleCellCheckbox(cell: UITableViewCell, completed: Bool) {
        if !completed {
            cell.accessoryType = UITableViewCellAccessoryType.None
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
    }
    
}
