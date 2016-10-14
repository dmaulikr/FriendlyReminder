//
//  EventViewController.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 2/24/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class EventViewController: UITableViewController {
    
    var events = [Event]()
    var user: User!
    var myConnectionsRef: FIRDatabaseReference?
    
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var activityView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        
        // initialize presence
        myConnectionsRef = FirebaseClient.Constants.USER_REF.child(user.id + "/connections/")
        FirebaseClient.sharedInstance().createPresence(myConnectionsRef!) {
            // check user's presence
            FirebaseClient.sharedInstance().checkPresence() {
                connected in
                if !connected {
                    Alerts.sharedInstance().createAlert("Lost Connection",
                        message: "Data will be refreshed once connection has been established!", VC: self, withReturn: false)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // get current user's events
        FirebaseClient.sharedInstance().getEvents(user.id) {
            (newEvents) -> Void in
            self.events = newEvents
            self.tableView.reloadData()
            self.activityView.isHidden = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        FirebaseClient.Constants.CONNECT_REF.removeAllObservers()
    }
    
    // initializes UI elements
    func initUI() {
        // initialize navbar
        navigationItem.title = "Group"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.addEvent))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(self.logoutUser))
        
        // initialize today's date in dateLabel
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, y"
        let today = dateFormatter.string(from: Date())
        dateLabel.text = "Welcome " + user.name + "! It is " + today
    }
    
    // goes to the view controller made to create events
    func addEvent() {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "EventCreatorViewController") as! EventCreatorViewController
        
        controller.user = user
        controller.groupEvent = true
        
        self.present(controller, animated: true, completion: nil)
    }
    
    // logs out the user
    func logoutUser() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        try! FIRAuth.auth()!.signOut()
        
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        let myLoginController = appDelegate.window!.rootViewController as! LoginViewController
        
        myLoginController.user = nil
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Configure Cell
    
    // configures cell
    func configureCell(_ cell: EventCell, indexPath: IndexPath) {
        let event = events[(indexPath as NSIndexPath).row]
        
        // changes the date format
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .long
        dateFormatter.dateFormat = "yyyyMMdd h:mm a"
        let oldDate = dateFormatter.date(from: event.date)
        dateFormatter.dateFormat = "MMMM d, y h:mm a"
        let dateString = dateFormatter.string(from: oldDate!)
        
        cell.title.text = event.title
        cell.dateOfEvent.text =  event.creator + "'s Event: " + dateString
        cell.tasksLeft.text = String(describing: event.taskCounter.value(forKey: user.name)!)
    }
  

    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "EventCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! EventCell
        
        configureCell(cell, indexPath: indexPath)

        return cell
    }
    
    // goes to task view controller when user selects an event
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = events[(indexPath as NSIndexPath).row]
        let controller = storyboard!.instantiateViewController(withIdentifier: "TaskViewController") as! TaskViewController
        
        // need to pass reference to event title
        controller.user = user
        controller.event = event
        controller.ref = event.ref!.child("tasks")
        controller.taskCounterRef = event.ref!.child("taskCounter")

        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        let event = events[(indexPath as NSIndexPath).row]
        // only lets creator delete
        if event.creator == user.name {
            return UITableViewCellEditingStyle.delete
        } else {
            return UITableViewCellEditingStyle.none
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
        forRowAt indexPath: IndexPath) {
            
            switch (editingStyle) {
            case .delete:
                let event = events[(indexPath as NSIndexPath).row]
                event.ref?.removeValue()
            default:
                break
            }
    }


}

