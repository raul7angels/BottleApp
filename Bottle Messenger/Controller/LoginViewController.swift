//
//  ViewController.swift
//  FamilyMessenger
//
//  Created by Paiste Family on 6/9/17.
//  Copyright © 2017 Bam Bam Labs. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var nicknameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        SVProgressHUD.show()
        if let nickname = nicknameField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: nickname, password: password) { (user, error) in
                if let error = error {
                    SVProgressHUD.dismiss()
                    Utils.displayAlert(targetVC: self, title: "Error", message: error.localizedDescription, button: "OK")
                } else {
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "goToChat", sender: self)
                }
            }
        }
        
    }
    
    
}

