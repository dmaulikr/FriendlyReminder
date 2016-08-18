//
//  Alerts.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 8/11/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

class Alerts {
    
    func createAlert(title: String, message: String, VC: UIViewController, withReturn: Bool) {
        let alert = UIAlertController(title: title,
            message: message,
            preferredStyle: .Alert)
        
        if(withReturn) {
            let cancelAction = UIAlertAction(title: "OK",
                style: .Default) { (action: UIAlertAction) -> Void in
                    VC.navigationController?.popViewControllerAnimated(true)
            }
            alert.addAction(cancelAction)
        } else {
            let cancelAction = UIAlertAction(title: "OK",
                style: .Default) { (action: UIAlertAction) -> Void in}
            alert.addAction(cancelAction)
        }

        VC.presentViewController(alert, animated: true, completion: nil)
    }
    
    class func sharedInstance() -> Alerts {
        struct Singleton {
            static var sharedInstance = Alerts()
        }
        return Singleton.sharedInstance
    }
}
