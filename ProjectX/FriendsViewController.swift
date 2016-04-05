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
    var membersRef: Firebase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Friends"
    }
    
    // reloads the tableview data and task array
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        FacebookClient.sharedInstance().searchForFriendsList(self.membersRef!) {
            (friends, picture, error) -> Void in
            self.friends = friends
            self.tableView.reloadData()
            
        }
    }
    
    @IBAction func addFriend(sender: AnyObject) {

    }
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "FriendCell"
        let friend = friends[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! FriendCell//as! TaskCancelingTableViewCell
        
        cell.friendName.text = friend.name
        cell.profilePic.image = friend.image
        if friend.isMember {
            cell.contentView.backgroundColor = UIColor.greenColor()
        } else {
            cell.contentView.backgroundColor = UIColor.blueColor()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: make the button unclickable and say ADDED!
        let friend = friends[indexPath.row]
        if friend.isMember == false {
            self.membersRef?.updateChildValues([friend.id: true])
            tableView.cellForRowAtIndexPath(indexPath)?.contentView.backgroundColor = UIColor.greenColor()
        }
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
