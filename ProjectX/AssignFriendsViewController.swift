//
//  AssignFriendsViewController.swift
//  ProjectX
//
//  Created by Jonathan Chou on 4/12/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import Firebase

class AssignFriendsViewController: UITableViewController {
    
    var friends = [Friend]()
    var membersRef: Firebase?
    var task: Task!
    var selectedFriends: [String] = []
        
    @IBOutlet weak var activityView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavBar()
    }
    
    // reloads the tableview data and task array
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        FacebookClient.sharedInstance().searchForFriendsList(self.membersRef!) {
            (friends, picture, error) -> Void in
            self.friends = friends
            self.tableView.reloadData()
            self.activityView.hidden = true
        }
    }
    
    func initNavBar() {
        navigationItem.title = "Assign Friends"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "assignFriends")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel")


    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func assignFriends() {
        // use selectedFriends to add to task.incharge
        if task.inCharge[0] == "no one" {
            task.inCharge = []
        }
        for name in selectedFriends {
            task.inCharge.append(name)
        }
        task.ref?.childByAppendingPath("inCharge").setValue(task.inCharge)
        self.navigationController?.popViewControllerAnimated(true)

    }

    
    func configureCell(cell: FriendCell, indexPath: NSIndexPath) {
        let friend = friends[indexPath.row]
        var isAssigned: Bool = false
        
        cell.friendName.text = friend.name
        cell.profilePic.image = friend.image

        for name in task.inCharge {
            if name == friend.name {
                isAssigned = true
            }
        }
        for name in selectedFriends {
            if name == friend.name {
                isAssigned = true
            }
        }
        toggleCellCheckbox(cell, isAssigned: isAssigned)
    }
    
    
    func toggleCellCheckbox(cell: UITableViewCell, isAssigned: Bool) {
        if !isAssigned {
            cell.accessoryType = UITableViewCellAccessoryType.None
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell.userInteractionEnabled = false
            cell.backgroundColor = UIColor.blackColor()
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let friend = friends[indexPath.row]
        selectedFriends.append(friend.name)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell!.userInteractionEnabled = false
        print("hi")

        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }

}

