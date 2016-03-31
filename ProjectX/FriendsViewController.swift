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
    }
    
    // reloads the tableview data and task array
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        FacebookClient.sharedInstance().searchForFriendsList() {
            (friends, picture, error) -> Void in
            
            self.friends = friends
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addFriend(sender: AnyObject) {
        //add to firebase, make the button unclickable and say ADDED!, change background tableviewcell to green?
        // make friend a member of event
        
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
