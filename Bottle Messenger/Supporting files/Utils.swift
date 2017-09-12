//
//  Utilities.swift
//  Snapchat
//
//  Created by Paiste Family on 21/8/17.
//  Copyright © 2017 Bam Bam Labs. All rights reserved.
//

import Foundation
import UIKit

extension String
{
    func  toDate( dateFormat format  : String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: self)
        {
            return date
        }
        print("Invalid arguments ! Returning Current Date . \(self)")
        return Date()
    }
}

class Utils {
    static func displayAlert(targetVC: UIViewController, title: String = "Error", message: String = "There was an error!", button: String = "Ok", segue: String? = nil) {
        
        // Define alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        // Define button
        
        alert.addAction(UIAlertAction(title: button, style: .default, handler: { (action) in
            if let segue = segue {
                targetVC.performSegue(withIdentifier: segue, sender: self)
            }
        }))
        
        // show the alert
        // targetVC.presentingViewController?.present(alert, animated: true, completion: nil)
        targetVC.present(alert, animated: true, completion: nil)
        
    }
    
}
