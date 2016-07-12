//
//  TaskViewController.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 3/10/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import Firebase

class TaskViewController: UITableViewController, iCarouselDataSource, iCarouselDelegate {
    
    var tasks = [Task]()
    var taskCounter = 0
    var user: User!
    var event: Event!
    var ref: FIRDatabaseReference? // reference to all tasks
    var taskCounterRef: FIRDatabaseReference!
    var friends = [Friend]()
    
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var carouselView: iCarousel!
    @IBOutlet weak var addFriendsButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavBar()
        
        // TODO: create a carouselview init?
        carouselView.bringSubviewToFront(addFriendsButton)
        
        carouselView.type = iCarouselType.Rotary
        
        // position offset from center
        carouselView.contentOffset = CGSize(width: 50, height: 0)
        
        //carouselView.scrollToItemBoundary = false
        
        // TODO: create custombutton class for buttons
        addFriendsButton.layer.cornerRadius = 10.0
        addFriendsButton.layer.borderWidth = 0.5
        addFriendsButton.layer.borderColor = UIColor.blueColor().CGColor
        addFriendsButton.titleLabel?.textAlignment = .Center
        
        // get task counter to update user's task counter for this event
        FirebaseClient.sharedInstance().getTaskCounter(taskCounterRef, userName: user.name) {
            taskCounter in
            self.taskCounter = taskCounter
        }
        
        FirebaseClient.sharedInstance().checkPresence() {
            connected in
            if !connected {
                let alert = UIAlertController(title: "Lost Connection",
                    message: "Data will be refreshed once connection has been established!",
                    preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: "OK",
                    style: .Default) { (action: UIAlertAction) -> Void in
                }
                alert.addAction(cancelAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        

    }
    
    // reloads the tableview data and task array
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ref!.observeEventType(.Value, withBlock: { snapshot in
            
            var newTasks = [Task]()
            
            for task in snapshot.children {
                let task = Task(snapshot: task as! FIRDataSnapshot)
                newTasks.append(task)
            }
            
            self.tasks = newTasks
            self.tableView.reloadData()
            self.activityView.hidden = true
        })
        
        FacebookClient.sharedInstance().searchForFriendsList(event.ref!.child("members/"), controller: self) {
            (friends, error) -> Void in
            self.friends = []
            for friend in friends {
                if friend.isMember {
                    self.friends.append(friend)
                }
            }
            if self.friends.count <= 1 {
                self.carouselView.scrollEnabled = false
            } else {
                self.carouselView.scrollEnabled = true
            }
            self.carouselView.reloadData()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        FirebaseClient.Constants.CONNECT_REF.removeAllObservers()
    }
    
    func initNavBar() {
        // initialize nav bar
        let label = UILabel(frame: CGRectMake(0, 0, 440, 44))
        label.backgroundColor = UIColor.clearColor()
        label.numberOfLines = 2
        label.textAlignment = NSTextAlignment.Center
        label.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        label.text = event.title
        navigationItem.titleView = label
        
        
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTask")
        navigationItem.rightBarButtonItem = addButton
    }
    
    // MARK: - Take task and Quit task button
    @IBAction func takeTask(sender: AnyObject) {
        let task = getTask(sender)
        let button = sender as! UIButton
        
        // assign user to task and increase user's task counter
        if button.titleLabel!.text == "Take task" {
            // appends to task.inCharge if it's nil
            if task.inCharge?.append(user.name) == nil {
                task.inCharge = [user.name]
            }
            button.setTitle("Quit task", forState: .Normal)
            taskCounterRef.updateChildValues([user.name: ++taskCounter])
        } else {
            // Quit task
            // remove user from inCharge list
            task.inCharge = task.inCharge!.filter{$0 != user.name}

            button.setTitle("Take task", forState: .Normal)
            taskCounterRef.updateChildValues([user.name: --taskCounter])
        }
        task.ref?.child("inCharge").setValue(task.inCharge)
    }
    
    // shows view controller which allows user to assign friends to task
    @IBAction func assignTask(sender: AnyObject) {
        let task = getTask(sender)
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("AssignFriendsViewController") as! AssignFriendsViewController
        controller.membersRef = event.ref!.child("members/")
        controller.task = task
        controller.taskCounterRef = self.taskCounterRef

        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    // button that completes the task
    // changes background of button to green
    // strikethrough task description
    @IBAction func completeTask(sender: AnyObject) {

        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! TaskCell
        let indexPath = tableView.indexPathForCell(cell)
        let task = tasks[indexPath!.row]
        
        // to make task incomplete
        if task.complete {
            // pinkColor values obtained from printing out the background color
            //let pinkColor = UIColor(colorLiteralRed: 1, green: 0.481462, blue: 0.53544, alpha: 1)
            let darkPurpleColor = UIColor(colorLiteralRed: 0.365776, green: 0.432844, blue: 0.577612, alpha: 1)
            cell.checkmarkButton.backgroundColor = darkPurpleColor
            cell.taskDescription.attributedText = nil
            cell.takeTask.userInteractionEnabled = true
            cell.assignButton.userInteractionEnabled = true
            
            task.ref?.child("complete").setValue(false)
            // update counters for all other people in charge
            taskCounterRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                for name in task.inCharge! {
                    var newCounter = snapshot.value![name] as! Int
                    self.taskCounterRef.updateChildValues([name: ++newCounter])
                    if name == self.user.name {
                        self.taskCounter = newCounter
                    }
                }
            })
        } else { // complete task
            let attributes = [
                NSStrikethroughStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)
            ]
            cell.taskDescription.attributedText = NSAttributedString(string: cell.taskDescription.text!, attributes: attributes)
            cell.checkmarkButton.backgroundColor = UIColor.greenColor()
            cell.userInteractionEnabled = false
            
            task.ref?.child("complete").setValue(true)
            taskCounterRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                for name in task.inCharge! {
                    var newCounter = snapshot.value![name] as! Int
                    self.taskCounterRef.updateChildValues([name: --newCounter])
                    if name == self.user.name {
                        self.taskCounter = newCounter
                    }
                }
            })
        }
    }
    
    // returns the current task from button press
    func getTask(sender: AnyObject) -> Task {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! TaskCell
        let indexPath = tableView.indexPathForCell(cell)
        let task = tasks[indexPath!.row]
        return task
    }
    
    // goes to friend view controller to see which friends can be added
    @IBAction func addFriends(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("FriendsViewController") as! FriendsViewController
        controller.membersRef = event.ref!.child("members/")
        controller.taskCounterRef = self.taskCounterRef
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    // creates an alert to add a task to the event
    func addTask() {
        let alert = UIAlertController(title: "Task creation",
            message: "Add a task",
            preferredStyle: .Alert)
        
        let createAction = UIAlertAction(title: "Create",
            style: .Default) { (action: UIAlertAction) -> Void in
                
                if alert.textFields![0].text == "" {
                    // creates another alert if task title is empty
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
                // checks for invalid characters
                for character in textField.text!.characters {
                    if self.isInvalid(character) {
                        // throws an alert for invalid characters
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
                // create task on Firebase
                let taskRef = self.ref!.child(textField.text!.lowercaseString + "/")
                let task = Task(title: textField.text!, creator: self.user.name, ref: taskRef)
                taskRef.setValue(task.toAnyObject())
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
    
    // checks to see if characters are invalid
    func isInvalid(myChar: Character) -> Bool {
        if myChar == "." || myChar == "#" || myChar == "$" || myChar == "/" || myChar == "[" || myChar == "]" {
            return true
        }
        return false
    }
    
    func configureCell(cell: TaskCell, indexPath: NSIndexPath) {
        let task = tasks[indexPath.row]

        // initial configuration
        cell.taskDescription.text = task.title
        cell.taskDescription.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
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
            for name in task.inCharge! {
                // can interact with only checkmark button
                if name == user.name {
                    cell.userInteractionEnabled = true
                    cell.takeTask.userInteractionEnabled = false
                    cell.assignButton.userInteractionEnabled = false
                }
            }
        }
        // if no one is in charge, reset the cell
        if task.inCharge == nil {
            // reset the cell
            cell.takeTask.hidden = false
            cell.takeTask.setTitle("Take task", forState: .Normal)
            cell.assignedToLabel.hidden = true
            cell.assignedPeople.hidden = true
            cell.userInteractionEnabled = true
            cell.takeTask.userInteractionEnabled = true
            cell.assignButton.userInteractionEnabled = true

        } else {
            cell.assignedPeople.text? = ""
            cell.assignedToLabel.hidden = false
            cell.assignedPeople.hidden = false
            
            // appends names to the assignedPeople label
            for name in task.inCharge! {
                if name == user.name {
                    cell.takeTask.setTitle("Quit task", forState: .Normal)
                    cell.checkmarkButton.hidden = false
                }
                cell.assignedPeople.text?.appendContentsOf(name + ", ")
            }
            // drops the last comma
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
        let task = tasks[indexPath.row]
        // only creator can delete task
        if task.creator == user.name {
            return UITableViewCellEditingStyle.Delete
        } else {
            return UITableViewCellEditingStyle.None
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            switch (editingStyle) {
            case .Delete:
                let task = tasks[indexPath.row]
                
                if task.inCharge != nil {
                    taskCounterRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                        for name in task.inCharge! {
                            var newCounter = snapshot.value![name] as! Int
                            self.taskCounterRef.updateChildValues([name: --newCounter])
                            if name == self.user.name {
                                self.taskCounter = newCounter
                            }
                        }
                    })
                }

                task.ref!.removeValue()
            default:
                break
            }
    }
    
    // MARK - iCarousel
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return friends.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var imageView : UIImageView!
        
        if view == nil {
            imageView = UIImageView(frame: CGRectMake(0,0,75,75))
            imageView.contentMode = .ScaleAspectFit
        } else {
            imageView = view as! UIImageView
        }

        var testIndex = index % 2
        if friends.count == 1 {
            testIndex = 0
        }
        
        imageView.image = friends[testIndex].image
        imageView.layer.cornerRadius = imageView.image!.size.width / 5.5
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.blackColor().CGColor
        imageView.layer.borderWidth = 2.0
        return imageView
        
    }
    
}
