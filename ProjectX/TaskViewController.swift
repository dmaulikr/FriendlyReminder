//
//  TaskViewController.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/10/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import Firebase

class TaskViewController: UITableViewController {
    var tasks = [Task]()
    var ref: Firebase? // reference to all tasks
    var eventRef: Firebase? // for friendVC
    var userRef: Firebase?
    var userName: String?
    var eventTitle: String!
    var taskCounter: Int = 0
    
    @IBOutlet weak var activityView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel(frame: CGRectMake(0, 0, 440, 44))
        label.backgroundColor = UIColor.clearColor()
        label.numberOfLines = 2
        label.textAlignment = NSTextAlignment.Center
        label.text = eventTitle
        navigationItem.titleView = label
        
        
       // navigationItem.title = eventTitle

        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTask")
        let addFriends = UIBarButtonItem(title: "Add Friends", style: .Plain, target: self, action: "addFriends")
        navigationItem.rightBarButtonItems = [addFriends, addButton]
        
        // get name of user
        userRef!.observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.userName = snapshot.value["name"] as? String
        })
        
        // get current taskCounter
        eventRef!.observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.taskCounter = snapshot.value["taskCounter"] as! Int
        })
    }
    
    // reloads the tableview data and task array
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        ref!.observeEventType(.Value, withBlock: { snapshot in
            
            var newTasks = [Task]()
            
            for task in snapshot.children {
                let task = Task(snapshot: task as! FDataSnapshot)
                newTasks.append(task)
            }
            
            self.tasks = newTasks
            self.tableView.reloadData()
            self.activityView.hidden = true
        })
    }
    
    // MARK: - Take Task
    @IBAction func takeTask(sender: AnyObject) {
        let task = getTask(sender)
        let button = sender as! UIButton

        if task.inCharge[0] == "no one" {
            task.inCharge = []
        }
        
        if button.titleLabel!.text == "Take task" {
            task.inCharge.append(self.userName!)
            button.setTitle("Quit task", forState: .Normal)
            eventRef!.updateChildValues(["taskCounter": ++taskCounter])

        } else { // Quit task
            var newArray: [String] = []
            // remove user from incharge list
            for name in task.inCharge {
                if name != self.userName {
                    newArray.append(name)
                }
            }
            if newArray == [] {
                newArray.append("no one")
            }
            task.inCharge = newArray
            button.setTitle("Take task", forState: .Normal)
            eventRef!.updateChildValues(["taskCounter": --taskCounter])

        }
        task.ref?.childByAppendingPath("inCharge").setValue(task.inCharge)
    }
    
    @IBAction func assignTask(sender: AnyObject) {
        let task = getTask(sender)
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("AssignFriendsViewController") as! AssignFriendsViewController
        controller.membersRef = eventRef?.childByAppendingPath("members/")
        controller.task = task
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    @IBAction func completeTask(sender: AnyObject) {
        //change background of button to green
        // strikethrough task description
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! TaskCell
        let indexPath = tableView.indexPathForCell(cell)
        let task = tasks[indexPath!.row]
        
        // if complete and want to undo
        if task.complete {
           // UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            let pinkColor = UIColor(colorLiteralRed: 1, green: 0.481462, blue: 0.53544, alpha: 1)
            cell.checkmarkButton.backgroundColor = pinkColor
            cell.taskDescription.attributedText = nil
            task.ref?.childByAppendingPath("complete").setValue(false)
            cell.takeTask.userInteractionEnabled = true
            cell.assignButton.userInteractionEnabled = true
            
            eventRef!.updateChildValues(["taskCounter": ++taskCounter])

        } else {
            cell.checkmarkButton.backgroundColor = UIColor.greenColor()
            let attributes = [
                // NSStrikethroughColorAttributeName: UIColor.blackColor(),
                NSStrikethroughStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)
            ]
            cell.taskDescription.attributedText = NSAttributedString(string: cell.taskDescription.text!, attributes: attributes)
            cell.userInteractionEnabled = false
            task.ref?.childByAppendingPath("complete").setValue(true)
            eventRef!.updateChildValues(["taskCounter": --taskCounter])

        }

    }
    
    func getTask(sender: AnyObject) -> Task {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! TaskCell
        let indexPath = tableView.indexPathForCell(cell)
        let task = tasks[indexPath!.row]
        return task
    }
    
    
    func addFriends() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("FriendsViewController") as! FriendsViewController
        controller.membersRef = eventRef?.childByAppendingPath("members/")
        self.navigationController!.pushViewController(controller, animated: true)
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
                for character in textField.text!.characters {
                    if self.isInvalid(character) {
                        let alert2 = UIAlertController(title: "Invalid task",
                            message: "Task description cannot contain '.' '#' '$' '/' '[' or ']'",
                            preferredStyle: .Alert)
                        
                        let cancelAction = UIAlertAction(title: "OK",
                            style: .Default) { (action: UIAlertAction) -> Void in
                        }
                        alert2.addAction(cancelAction)
                        
                        self.presentViewController(alert2, animated: true, completion: nil)
                        return
                    }
                }
                // check text for symbols Must be a non-empty string and not contain '.' '#' '$' '[' or ']''
                let taskRef = self.ref!.childByAppendingPath(textField.text!.lowercaseString + "/")

                let task = Task(title: textField.text!, creator: self.userName!, ref: taskRef)

                taskRef.setValue(task.toAnyObject())
                //self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(cancelAction)
        alert.addAction(createAction)

        
        // fixes collection view error
        alert.view.setNeedsLayout()
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func isInvalid(myChar: Character) -> Bool {
        if myChar == "." || myChar == "#" || myChar == "$" || myChar == "/" || myChar == "[" || myChar == "]" {
            return true
        }
        return false
    }
    
    func configureCell(cell: TaskCell, indexPath: NSIndexPath) {
        let task = tasks[indexPath.row]

        cell.taskDescription.text = task.title
        cell.creator.text = task.creator
        cell.selectionStyle = .None
        cell.checkmarkButton.hidden = true
        // if task is done, show check button that is green and strikethrough description
        // cant interact with cell unless you are part of the assigned people
        if task.complete {
            cell.checkmarkButton.hidden = false
            cell.checkmarkButton.backgroundColor = UIColor.greenColor()
            let attributes = [
                NSStrikethroughStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)
            ]
            cell.taskDescription.attributedText = NSAttributedString(string: cell.taskDescription.text!, attributes: attributes)
            cell.userInteractionEnabled = false
            for name in task.inCharge {
                // can interact with only checkmark button
                if name == userName {
                    cell.userInteractionEnabled = true
                    cell.takeTask.userInteractionEnabled = false
                    cell.assignButton.userInteractionEnabled = false
                }
            }
        }

        
        if task.inCharge == ["no one"] {
            // reset the cell
            cell.takeTask.hidden = false
            cell.takeTask.setTitle("Take task", forState: .Normal)
            cell.assignedToLabel.hidden = true
            cell.assignedPeople.hidden = true
           // cell.assignedPeople.text? = ""

        } else {
            cell.assignedPeople.text? = ""
            cell.assignedToLabel.hidden = false
            cell.assignedPeople.hidden = false
            

            for name in task.inCharge {
                if name == userName {
                    cell.takeTask.setTitle("Quit task", forState: .Normal)
                    cell.checkmarkButton.hidden = false
                }
                cell.assignedPeople.text?.appendContentsOf(name + ", ")
            }
            cell.assignedPeople.text? = String(cell.assignedPeople.text!.characters.dropLast().dropLast())
        }
    }
    
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "TaskCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! TaskCell
        
        configureCell(cell, indexPath: indexPath)

        return cell
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        return UITableViewCellEditingStyle.None
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            switch (editingStyle) {
            case .Delete:
                let task = tasks[indexPath.row]
                print("\(task.ref)")
                task.ref!.removeValue()
            default:
                break
            }
    }
}