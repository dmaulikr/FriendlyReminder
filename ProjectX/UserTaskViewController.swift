//
//  UserTaskViewController.swift
//  FriendlyReminder
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
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.addTask))
        navigationItem.rightBarButtonItems = [addButton]
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
    }
    
    func addTask() {
        let alert = UIAlertController(title: "Task creation",
            message: "Add a task",
            preferredStyle: .alert)
        
        let createAction = UIAlertAction(title: "Create",
            style: .default) { (action: UIAlertAction) -> Void in
                
                if alert.textFields![0].text == "" {
                    Alerts.sharedInstance().createAlert("Task title",
                        message: "Task title can't be empty!", VC: self, withReturn: false)
                    return
                }
                let textField = alert.textFields![0]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let createdAt = dateFormatter.string(from: Date())
                // create a UserTask into CoreData
                let _ = UserTask(title: textField.text!, created: createdAt, event: self.userEvent,
                                 context: self.sharedContext)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextField {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        
        // fixes collection view error
        alert.view.setNeedsLayout()
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Core Data Convenience.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<UserTask> = {
        let fetchRequest = NSFetchRequest<UserTask>(entityName: "UserTask")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "event == %@", self.userEvent)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - Fetched Results Controller Delegate
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            case .update:
                let cell = tableView.cellForRow(at: indexPath!)!
                let task = controller.object(at: indexPath!) as! UserTask
                toggleCellCheckbox(cell, completed: task.isDone)
            default:
                break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // need to reload tableView and save changes to core data
        tableView.reloadData()
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "UserTaskCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)! as UITableViewCell
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userTask = fetchedResultsController.object(at: indexPath) as! UserTask
        // triggers update
        userTask.isDone = !userTask.isDone
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
        forRowAt indexPath: IndexPath) {
            
        switch (editingStyle) {
            case .delete:
                let userTask = fetchedResultsController.object(at: indexPath) as! UserTask
                
                // delete object from fetchedResultsController
                sharedContext.delete(userTask)
            default:
                break
        }
    }
    
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        let task = fetchedResultsController.object(at: indexPath) as! UserTask
        toggleCellCheckbox(cell, completed: task.isDone)
        cell.textLabel?.text = task.title
    }
    
    func toggleCellCheckbox(_ cell: UITableViewCell, completed: Bool) {
        if !completed {
            cell.textLabel?.attributedText = nil
            cell.accessoryType = UITableViewCellAccessoryType.none
        } else {
            cell.tintColor = UIColor.orange
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            let attributes = [
                NSStrikethroughStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue as Int)
            ]
            cell.textLabel?.attributedText = NSAttributedString(string: cell.textLabel!.text!, attributes: attributes)

        }
    }
}
