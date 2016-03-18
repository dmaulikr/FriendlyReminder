//
//  FriendsViewController.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/17/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import Firebase

class FriendsViewController: UITableViewController {
    
    var friends = [Friend]()
    var ref: Firebase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Friends"
        navigationItem.rightBarButtonItems = [self.editButtonItem()]
       // let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTask")
        //navigationItem.rightBarButtonItems = [self.editButtonItem(), addButton]
    }
    
    // reloads the tableview data and task array
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        /*
        ref!.observeEventType(.Value, withBlock: { snapshot in
            
            var newTasks = [Task]()
            
            for task in snapshot.children {
                let task = Task(snapshot: task as! FDataSnapshot)
                newTasks.append(task)
            }
            
            self.tasks = newTasks
            self.tableView.reloadData()
        })
*/
        FacebookClient.sharedInstance().searchForFriendsList() {
            (result, error) -> Void in
            var newFriends = [Friend]()
            for friend in result {
                print(friend)
                print(result)
                let friend = Friend(name: friend["name"] as! String)
                newFriends.append(friend)
            }
            
            self.friends = newFriends
            self.tableView.reloadData()
        }
    }
 /*
    func addTask() {
        // alert to add task
        
        // Alert View for input
        let alert = UIAlertController(title: "Task creation",
            message: "Add a task",
            preferredStyle: .Alert)
        
        let createAction = UIAlertAction(title: "Create",
            style: .Default) { (action: UIAlertAction) -> Void in
                
                let textField = alert.textFields![0]
                let task = Task(title: textField.text!, creator: self.userName!)
                let taskRef = self.ref!.childByAppendingPath(task.title.lowercaseString + "/")
                
                taskRef.setValue(task.toAnyObject())
                //self.tableView.reloadData()
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
  */
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let sectionInfo = self.fetchedResultsController.sections![section]
        //return sectionInfo.numberOfObjects
        return friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "FriendCell"
        
        let friend = friends[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)! as UITableViewCell//as! TaskCancelingTableViewCell
        
        // This is the new configureCell method
        //configureCell(cell, event: event)
        cell.textLabel?.text = friend.name
        //cell.detailTextLabel?.text = task.creator
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            switch (editingStyle) {
            case .Delete: break
                //let task = friends[indexPath.row]
                //print("\(task.ref)")
                //task.ref!.removeValue()
            default:
                break
            }
    }
}
