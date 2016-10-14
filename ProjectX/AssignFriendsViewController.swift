//
//  AssignFriendsViewController.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 4/12/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import Firebase

class AssignFriendsViewController: UITableViewController {
    
    var friendMems = [Friend]()
    var membersRef: FIRDatabaseReference?
    var task: Task!
    var selectedFriends: [Friend] = []
    var taskCounterRef: FIRDatabaseReference!
        
    @IBOutlet weak var activityView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavBar()
    }
    
    // reloads the tableview data and friends array
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FacebookClient.sharedInstance().searchForFriendsList(self.membersRef!, controller: self) {
            (friends, error) -> Void in
            self.activityView.isHidden = true
            for friend in friends {
                if friend.isMember {
                    self.friendMems.append(friend)
                }
            }
            // if no friends found, present an alert
            if self.friendMems.count == 0 {
                Alerts.sharedInstance().createAlert("No Friends Found",
                    message: "Add friends to the event first!", VC: self, withReturn: true)
            }
            self.tableView.reloadData()
        }
    }
    
    func initNavBar() {
        navigationItem.title = "Assign Friends"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Assign", style: .plain, target: self, action: #selector(self.assignFriends))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancel))
    }
    
    func cancel() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // assigns friends to the task
    func assignFriends() {
        // use selectedFriends to add to task.incharge
        if selectedFriends.isEmpty {
            Alerts.sharedInstance().createAlert("No Friends Selected",
                message: "Select friends to add!", VC: self, withReturn: false)
            return
        }
        for friend in selectedFriends {
            // checks for nil
            // if it's not nil, it appends
            // if it is nil, it initializes the array
            if task.inCharge?.append(friend.name) == nil {
                task.inCharge = [friend.name]
            }

        }
        // increase task counter for selected friends
        taskCounterRef.observeSingleEvent(of: .value, with: { snapshot in
            for friend in self.selectedFriends {
               // var taskCounter = snapshot.value![friend.name] as! Int
                var taskCounter = (snapshot.value as? NSDictionary)?[friend.name] as? Int ?? 0

                
                taskCounter += 1
                self.taskCounterRef.updateChildValues([friend.name: taskCounter])
            }
        })

        task.ref?.child("inCharge").setValue(task.inCharge)
        _ = self.navigationController?.popViewController(animated: true)
    }

    
    func configureCell(_ cell: FriendCell, indexPath: IndexPath) {
        let friend = friendMems[(indexPath as NSIndexPath).row]
        var isAssigned: Bool = false
        
        // only if friend has been added to the event
        if friend.isMember {
            cell.friendName.text = friend.name
            cell.profilePic.image = friend.image
            
            if task.inCharge != nil {
                for name in task.inCharge! {
                    if name == friend.name {
                        isAssigned = true
                        // disable cell if friend has already been added to the task
                        cell.isUserInteractionEnabled = false
                    }
                }
            }
            for thisFriend in selectedFriends {
                if thisFriend.name == friend.name {
                    isAssigned = true
                }
            }
            toggleCellCheckbox(cell, isAssigned: isAssigned)
        }
    }
    
    
    func toggleCellCheckbox(_ cell: UITableViewCell, isAssigned: Bool) {
        let orangeColor = UIColor(colorLiteralRed: 0.891592, green: 0.524435, blue: 0.008936, alpha: 1)
        let darkBlueColor = UIColor(colorLiteralRed: 0.146534, green: 0.187324, blue: 0.319267, alpha: 1)
        if !isAssigned {
            cell.accessoryType = UITableViewCellAccessoryType.none
        } else {
            cell.tintColor = orangeColor
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            cell.backgroundColor = darkBlueColor
        }
    }
    
    // MARK: - Table View
    
    // only account for user's friends that are also members of the event
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendMems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "FriendCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! FriendCell
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = friendMems[(indexPath as NSIndexPath).row]
        var delete = false
        // removes friend from selection if user taps again
        for thisFriend in selectedFriends {
            if thisFriend.name == friend.name {
                selectedFriends = selectedFriends.filter{$0.name != friend.name}
                delete = true
            }
        }
        // adds friend into selected friends
        if !delete {
            selectedFriends.append(friend)
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
}

