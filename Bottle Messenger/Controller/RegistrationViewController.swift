//
//  RegistrationViewController.swift
//  FamilyMessenger
//
//  Created by Paiste Family on 6/9/17.
//  Copyright © 2017 Bam Bam Labs. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SVProgressHUD

class RegistrationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageUploaderDelegate {
    
    var imageUploader = ImageUploader()
    
    var user: User = User(id: "", email: "")
    
    @IBOutlet weak var nicknameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var profilePhotoView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageUploader.delegate = self
    }
    
    func photoURLReturned(photo: UIImage, thumbnail: UIImage, url: String, url_tn: String) {
        profilePhotoView.image = thumbnail
        user.fullSizePhotoURL = url
        user.photoURL = url_tn
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        SVProgressHUD.show()
        
        if let nickname = nicknameField.text, let password = passwordField.text, nickname.count > 2, password.count > 5 {
            user.email = nickname
            Auth.auth().createUser(withEmail: nickname, password: password) { (registeredUser, error) in
                if let error = error {
                    SVProgressHUD.dismiss()
                    Utils.displayAlert(targetVC: self, title: "Error", message: error.localizedDescription, button: "Ok")
                    return
                } else {
                    if let registeredUser = registeredUser {
                        Database.database().reference().child("users").child(registeredUser.uid).child("email").setValue(registeredUser.email)
                        if let photoURL = self.user.photoURL, let fullSizePhotoURL = self.user.fullSizePhotoURL {
                            Database.database().reference().child("users").child(registeredUser.uid).child("photoURL").setValue(photoURL)
                            Database.database().reference().child("users").child(registeredUser.uid).child("fullSizePhotoURL").setValue(fullSizePhotoURL)
                        }
                        SVProgressHUD.dismiss()
                        Utils.displayAlert(targetVC: self, title: "Congrats", message: "You have successfully created an account!", button: "Log in", segue: "goToChat")
                    }
                    
                }
            }
            
        }
    }
    

    @IBAction func photoUploadPressed(_ sender: Any) {
        imageUploader.pickImage(viewController: self, folder: "profilePhotos", tn_width: 102, width: 500)
    }
}
