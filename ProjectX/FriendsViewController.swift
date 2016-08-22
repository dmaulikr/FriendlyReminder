//
//  FriendsViewController.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 3/17/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import Firebase

class FriendsViewController: UITableViewController {
    
    var friends = [Friend]()
    var membersRef: FIRDatabaseReference!
    var taskCounterRef: FIRDatabaseReference!
    var taskRef: FIRDatabaseReference?
    
    @IBOutlet weak var activityView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavBar()
    }
    
    // reloads the tableview data and task array
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // searches for user's friends list
        FacebookClient.sharedInstance().searchForFriendsList(self.membersRef!, controller: self) {
            (friends, error) -> Void in
            if friends.isEmpty {
                Alerts.sharedInstance().createAlert("No Friends Found",
                    message: "No friends found with the app installed!", VC: self, withReturn: true)
            }
            self.friends = friends
            self.tableView.reloadData()
            self.activityView.hidden = true
        }
    }
    
    func initNavBar() {
        navigationItem.title = "Friends"
        let infoButton = UIButton(type: UIButtonType.InfoLight) as UIButton
        let rightBarButton = UIBarButtonItem()
        infoButton.frame = CGRectMake(0,0,30,30)
        infoButton.addTarget(self, action: #selector(self.showInfo), forControlEvents: .TouchUpInside)
        rightBarButton.customView = infoButton
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func showInfo() {
        Alerts.sharedInstance().createAlert("Instructions",
            message: "Tap friends to add them to the event!", VC: self, withReturn: false)
    }
    
    func configureCell(cell: FriendCell, indexPath: NSIndexPath) {
        let friend = friends[indexPath.row]
        let orangeColor = UIColor(colorLiteralRed: 0.891592, green: 0.524435, blue: 0.008936, alpha: 1)
        let darkBlueColor = UIColor(colorLiteralRed: 0.146534, green: 0.187324, blue: 0.319267, alpha: 1)


        cell.friendName.text = friend.name
        cell.profilePic.image = friend.image
        cell.tintColor = orangeColor
        cell.backgroundColor = darkBlueColor
        if friend.isMember {
            cell.accessoryType = .Checkmark
            cell.addedLabel.hidden = false
        } else {
            // remove checkmark
            cell.accessoryType = .None
            cell.addedLabel.hidden = true
        }
    }
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "FriendCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! FriendCell
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let friend = friends[indexPath.row]
        if friend.isMember == false {
            self.membersRef?.updateChildValues([friend.id: true])
            // initializes path to taskCounter in Firebase
            self.taskCounterRef.updateChildValues([friend.name: 0])
            friend.isMember = true
        } else {
            // removing friend from event
            self.membersRef?.updateChildValues([friend.id: false])
            friend.isMember = false
            // also remove from all tasks
            
            taskRef!.observeSingleEventOfType(.Value, withBlock: { snapshot in
                for task in snapshot.children {
                    //print(task)
                    let task = Task(snapshot: task as! FIRDataSnapshot)
                    if task.inCharge != nil {
                        for person in task.inCharge! {
                            if person == friend.name {
                                let newRef = self.taskRef!.child(task.title)
                                newRef.updateChildValues(["inCharge": task.inCharge!.filter{$0 != person}])
                                break
                            }
                        }
                    }
                }
            })
            // also update friend's taskcounter
            taskCounterRef.updateChildValues([friend.name: 0])
        }
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
}
