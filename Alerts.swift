//
//  Alerts.swift
//  FriendlyReminder
//
//  Created by Jonathan Chou on 8/11/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

class Alerts {
    
    func createAlert(_ title: String, message: String, VC: UIViewController, withReturn: Bool) {
        let alert = UIAlertController(title: title,
            message: message,
            preferredStyle: .alert)
        
        if(withReturn) {
            let cancelAction = UIAlertAction(title: "OK",
                style: .default) { (action: UIAlertAction) -> Void in
                    VC.navigationController?.popViewController(animated: true)
            }
            alert.addAction(cancelAction)
        } else {
            let cancelAction = UIAlertAction(title: "OK",
                style: .default) { (action: UIAlertAction) -> Void in}
            alert.addAction(cancelAction)
        }

        VC.present(alert, animated: true, completion: nil)
    }
    
    class func sharedInstance() -> Alerts {
        struct Singleton {
            static var sharedInstance = Alerts()
        }
        return Singleton.sharedInstance
    }
}
