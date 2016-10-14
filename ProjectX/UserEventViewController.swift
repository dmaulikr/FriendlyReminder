//
//  UserEventViewController.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 3/30/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import CoreData

class UserEventViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()

        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
    }
    
    func initUI() {
        // init navbar
        navigationItem.title = "Personal"
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.addUserEvent))
        let infoButton = UIButton(type: UIButtonType.infoLight) as UIButton
        let leftBarButton = UIBarButtonItem()
        infoButton.frame = CGRect(x: 0,y: 0,width: 30,height: 30)
        infoButton.addTarget(self, action: #selector(self.showInfo), for: .touchUpInside)
        leftBarButton.customView = infoButton
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = leftBarButton
        
        // init date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, y"
        let today = dateFormatter.string(from: Date())
        dateLabel.text = today
    }
    
    func showInfo() {
        Alerts.sharedInstance().createAlert("Instructions",
            message: "Swipe left to delete", VC: self, withReturn: false)
    }
    
    func addUserEvent() {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "EventCreatorViewController") as! EventCreatorViewController
        
        controller.groupEvent = false
        
        self.present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Core Data Convenience.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // MARK: - Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController<UserEvent> = {
        
        let fetchRequest = NSFetchRequest<UserEvent>(entityName: "UserEvent")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // reload tableView and save changes to core data
        tableView.reloadData()
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // MARK: - Configure Cell
    
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        let event = fetchedResultsController.object(at: indexPath) 
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .long
        dateFormatter.dateFormat = "yyyyMMdd h:mm a"
        let oldDate = dateFormatter.date(from: event.date)
        dateFormatter.dateFormat = "MMMM d, y h:mm a"
        let dateString = dateFormatter.string(from: oldDate!)
        
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = "Date of Event: " + dateString
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "EventCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)! as UITableViewCell
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "UserTaskViewController") as! UserTaskViewController
        
        controller.userEvent = fetchedResultsController.object(at: indexPath) 
        self.navigationController!.pushViewController(controller, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
        forRowAt indexPath: IndexPath) {
        switch (editingStyle) {
            case .delete:
                let userEvent = fetchedResultsController.object(at: indexPath) 
                
                // delete object from fetchedResultsController
                sharedContext.delete(userEvent)
            default:
                break
        }
    }
}
