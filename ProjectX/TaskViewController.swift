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
    @IBOutlet weak var carouselFriendName: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavBar()
        
        // TODO: create a carouselview init?
        carouselView.bringSubview(toFront: addFriendsButton)
        
        carouselView.type = iCarouselType.rotary
        
        //carouselView.scrollToItemBoundary = false
        
        // TODO: create custombutton class for buttons
        addFriendsButton.layer.cornerRadius = 10.0
        addFriendsButton.layer.borderWidth = 0.5
        addFriendsButton.layer.borderColor = UIColor.blue.cgColor
        addFriendsButton.titleLabel?.textAlignment = .center
        
        // hide addFriendsButton if not creator
        if event.creator != user.name {
            addFriendsButton.isHidden = true
            // can also adjust icarousel?
        } else {
            // position offset from center
            //carouselView.contentOffset = CGSize(width: 30, height: 0)
        }
        
        // get task counter to update user's task counter for this event
        FirebaseClient.sharedInstance().getTaskCounter(taskCounterRef, userName: user.name) {
            taskCounter in
            self.taskCounter = taskCounter
        }
        
        FirebaseClient.sharedInstance().checkPresence() {
            connected in
            if !connected {
                Alerts.sharedInstance().createAlert("Lost Connection",
                    message: "Data will be refreshed once connection has been established!", VC: self, withReturn: false)
            }
        }
    }
    
    // reloads the tableview data and task array
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ref!.observe(.value, with: { snapshot in
            
            var newTasks = [Task]()
            
            for task in snapshot.children {
                let task = Task(snapshot: task as! FIRDataSnapshot)
                newTasks.append(task)
            }
            
            self.tasks = newTasks
            self.tableView.reloadData()
            self.activityView.isHidden = true
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
                self.carouselView.isScrollEnabled = false
            } else {
                self.carouselView.isScrollEnabled = true
            }
            self.carouselView.reloadData()
            self.carouselCurrentItemIndexDidChange(self.carouselView)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        FirebaseClient.Constants.CONNECT_REF.removeAllObservers()
    }
    
    func initNavBar() {
        // initialize nav bar
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 440, height: 44))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        label.textAlignment = NSTextAlignment.center
        label.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
        label.text = event.title
        navigationItem.titleView = label
        
        
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.addTask))
        navigationItem.rightBarButtonItem = addButton
    }
    
    // MARK: - Take task and Quit task button
    @IBAction func takeTask(_ sender: AnyObject) {
        let task = getTask(sender)
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! TaskCell
        
        // assign user to task and increase user's task counter
        if button.titleLabel!.text == "Take task" {
            // appends to task.inCharge if it's nil
            if task.inCharge?.append(user.name) == nil {
                task.inCharge = [user.name]
            }
            button.setTitle("Quit task", for: UIControlState())
            taskCounter += 1
            taskCounterRef.updateChildValues([user.name: taskCounter])
            self.enhanceAnim(cell, button: button)
        } else {
            // Quit task
            // remove user from inCharge list
            task.inCharge = task.inCharge!.filter{$0 != user.name}

            button.setTitle("Take task", for: UIControlState())
            taskCounter -= 1
            taskCounterRef.updateChildValues([user.name: taskCounter])
            self.shrinkAnim(cell, button: button)
        }
        task.ref?.child("inCharge").setValue(task.inCharge)
    }
    
    // shows view controller which allows user to assign friends to task
    @IBAction func assignTask(_ sender: AnyObject) {
        let task = getTask(sender)
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "AssignFriendsViewController") as! AssignFriendsViewController
        controller.membersRef = event.ref!.child("members/")
        controller.task = task
        controller.taskCounterRef = self.taskCounterRef

        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    // button that completes the task
    // changes background of button to green
    // strikethrough task description
    @IBAction func completeTask(_ sender: AnyObject) {

        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! TaskCell
        let indexPath = tableView.indexPath(for: cell)
        let task = tasks[(indexPath! as NSIndexPath).row]
        //cell.takeTask.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        //UIView.setAnimationsEnabled(true)

        // to make task incomplete
        if task.complete {
            cell.assignButton.alpha = 1.0
            cell.takeTask.alpha = 1.0
            // pinkColor values obtained from printing out the background color
            //let pinkColor = UIColor(colorLiteralRed: 1, green: 0.481462, blue: 0.53544, alpha: 1)
            let darkPurpleColor = UIColor(colorLiteralRed: 0.365776, green: 0.432844, blue: 0.577612, alpha: 1)
            cell.checkmarkButton.backgroundColor = darkPurpleColor
            cell.taskDescription.attributedText = nil
            cell.takeTask.isUserInteractionEnabled = true
            cell.assignButton.isUserInteractionEnabled = true
            
            task.ref?.child("complete").setValue(false)
            // update counters for all other people in charge
            taskCounterRef.observeSingleEvent(of: .value, with: { snapshot in
                for name in task.inCharge! {
                    //var newCounter = snapshot.value![name] as! Int
                    var newCounter = (snapshot.value as? NSDictionary)?[name] as? Int ?? 0
                    newCounter += 1
                    self.taskCounterRef.updateChildValues([name: newCounter])
                    if name == self.user.name {
                        self.taskCounter = newCounter
                    }
                }
            })
        } else { // complete task
            let attributes = [
                NSStrikethroughStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue as Int)
            ]
            cell.taskDescription.attributedText = NSAttributedString(string: cell.taskDescription.text!, attributes: attributes)
            cell.checkmarkButton.backgroundColor = UIColor.green
            cell.isUserInteractionEnabled = false
            
            task.ref?.child("complete").setValue(true)
            taskCounterRef.observeSingleEvent(of: .value, with: { snapshot in
                for name in task.inCharge! {
                    //var newCounter = snapshot.value![name] as! Int
                    var newCounter = (snapshot.value as? NSDictionary)?[name] as? Int ?? 0

                    newCounter -= 1
                    self.taskCounterRef.updateChildValues([name: newCounter])
                    if name == self.user.name {
                        self.taskCounter = newCounter
                    }
                }
            })
            
            // animate other buttons disappearing
            button.isEnabled = false
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveLinear, animations: {
                cell.takeTask.alpha = 0.0
                cell.assignButton.alpha = 0.0
                }, completion: {
                    _ in
                    button.isEnabled = true
            })
        }
    }
    
    // returns the current task from button press
    func getTask(_ sender: AnyObject) -> Task {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! TaskCell
        let indexPath = tableView.indexPath(for: cell)
        let task = tasks[(indexPath! as NSIndexPath).row]
        return task
    }
    
    // goes to friend view controller to see which friends can be added
    @IBAction func addFriends(_ sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "FriendsViewController") as! FriendsViewController
        controller.membersRef = event.ref!.child("members/")
        controller.taskCounterRef = self.taskCounterRef
        controller.taskRef = event.ref!.child("tasks/")
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    // creates an alert to add a task to the event
    func addTask() {
        let alert = UIAlertController(title: "Task creation",
            message: "Add a task",
            preferredStyle: .alert)
        
        let createAction = UIAlertAction(title: "Create",
            style: .default) { (action: UIAlertAction) -> Void in
                
                if alert.textFields![0].text == "" {
                    // creates another alert if task title is empty
                    Alerts.sharedInstance().createAlert("Task title",
                        message: "Task title can't be empty!", VC: self, withReturn: false)
                    return
                }
                let textField = alert.textFields![0]
                // checks for invalid characters
                for character in textField.text!.characters {
                    if self.isInvalid(character) {
                        // throws an alert for invalid characters
                        Alerts.sharedInstance().createAlert("Invalid task",
                            message: "Task description cannot contain '.' '#' '$' '/' '[' or ']'", VC: self, withReturn: false)
                        return
                    }
                }
                // create task on Firebase
                let taskRef = self.ref!.child(textField.text!.lowercased() + "/")
                let task = Task(title: textField.text!, creator: self.user.name, ref: taskRef)
                taskRef.observeSingleEvent(of: .value, with: {
                    snapshot in
                    if snapshot.exists() {
                        Alerts.sharedInstance().createAlert("Task title taken",
                            message: "Please use a different task title.", VC: self, withReturn: false)
                    } else {
                        taskRef.setValue(task.toAnyObject())
                        //self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextField {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(cancelAction)
        alert.addAction(createAction)

        // fixes collection view error
        alert.view.setNeedsLayout()
        
        present(alert, animated: true, completion: nil)
    }
    
    // checks to see if characters are invalid
    func isInvalid(_ myChar: Character) -> Bool {
        if myChar == "." || myChar == "#" || myChar == "$" || myChar == "/" || myChar == "[" || myChar == "]" {
            return true
        }
        return false
    }
    
    func configureCell(_ cell: TaskCell, indexPath: IndexPath) {
        let task = tasks[(indexPath as NSIndexPath).row]

        // initial configuration
        cell.taskDescription.text = task.title
        cell.taskDescription.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
        cell.creator.text = task.creator
        cell.selectionStyle = .none
        
        // if task is done, show check button that is green and strikethrough description
        // cant interact with cell unless you are part of the assigned people
        if task.complete {
            cell.checkmarkButton.isHidden = false
            cell.checkmarkButton.isEnabled = true
            cell.checkmarkButton.backgroundColor = UIColor.green
            let attributes = [
                NSStrikethroughStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue as Int)
            ]
            cell.taskDescription.attributedText = NSAttributedString(string: cell.taskDescription.text!, attributes: attributes)
            cell.isUserInteractionEnabled = false
            for name in task.inCharge! {
                // can interact with only checkmark button
                if name == user.name {
                    cell.isUserInteractionEnabled = true
                    cell.takeTask.isUserInteractionEnabled = false
                    cell.assignButton.isUserInteractionEnabled = false
                }
            }
        }
        // if no one is in charge, reset the cell
        if task.inCharge == nil {
            // reset the cell
            cell.takeTask.setTitle("Take task", for: UIControlState())
            cell.assignedToLabel.isHidden = true
            cell.assignedPeople.isHidden = true
            cell.isUserInteractionEnabled = true
            cell.takeTask.isUserInteractionEnabled = true
            cell.assignButton.isUserInteractionEnabled = true

        } else {
            cell.assignedPeople.text? = ""
            cell.assignedToLabel.isHidden = false
            cell.assignedPeople.isHidden = false
            
            // appends names to the assignedPeople label
            for name in task.inCharge! {
                if name == user.name {
                    cell.takeTask.setTitle("Quit task", for: UIControlState())
                    cell.checkmarkButton.isHidden = false
                }
                cell.assignedPeople.text?.append(name + ", ")
            }
            // drops the last comma
            cell.assignedPeople.text? = String(cell.assignedPeople.text!.characters.dropLast().dropLast())
        }
    }
    
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "TaskCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! TaskCell
        
        configureCell(cell, indexPath: indexPath)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let task = tasks[(indexPath as NSIndexPath).row]
        // only creator can delete task
        if task.creator == user.name {
            return UITableViewCellEditingStyle.delete
        } else {
            return UITableViewCellEditingStyle.none
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
        forRowAt indexPath: IndexPath) {
            
            switch (editingStyle) {
            case .delete:
                let task = tasks[(indexPath as NSIndexPath).row]
                
                if task.inCharge != nil {
                    taskCounterRef.observeSingleEvent(of: .value, with: { snapshot in
                        for name in task.inCharge! {
                           // var newCounter = snapshot.value![name] as! Int
                            var newCounter = (snapshot.value as? NSDictionary)?[name] as? Int ?? 0

                            newCounter -= 1
                            self.taskCounterRef.updateChildValues([name: newCounter])
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
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return friends.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var imageView : UIImageView!
        
        if view == nil {
            imageView = UIImageView(frame: CGRect(x: 0,y: 0,width: 75,height: 75))
            imageView.contentMode = .scaleAspectFit
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
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 2.0
        return imageView
        
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        if(carousel.currentItemIndex >= 0 && carousel.currentItemIndex < friends.count) {
            carouselFriendName.text = friends[carousel.currentItemIndex].name
        } else {
            carouselFriendName.text = ""
        }
    }
    
    // MARK - Animations
    
    func shrinkAnim(_ cell: TaskCell, button: UIButton) {
        button.isEnabled = false
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .beginFromCurrentState, animations: {
            cell.checkmarkButton.transform = cell.checkmarkButton.transform.scaledBy(x: 0.2, y: 0.2)
            },  completion: {
                check in
                cell.checkmarkButton.transform = CGAffineTransform.identity
                if(check) {
                    cell.checkmarkButton.isHidden = true
                    button.isEnabled = true
                } else {
                    self.shrinkAnim(cell, button: button)
                }
        })
    }
    
    func enhanceAnim(_ cell: TaskCell, button: UIButton) {
        button.isEnabled = false
        cell.checkmarkButton.isHidden = false
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
            cell.checkmarkButton.transform = cell.checkmarkButton.transform.scaledBy(x: 1.3, y: 1.3)
            }, completion: {
                check in
                if(check) {
                    UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
                        cell.checkmarkButton.transform = CGAffineTransform.identity
                        }, completion: {
                            _ in
                            button.isEnabled = true
                    })
                } else {
                    cell.checkmarkButton.transform = CGAffineTransform.identity
                    self.enhanceAnim(cell, button: button)
                }
        })
    }
    
}
