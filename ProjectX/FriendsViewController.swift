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
            (friends, error) -> Void in
            
            self.friends = friends
            self.tableView.reloadData()
        }
    }
    
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
