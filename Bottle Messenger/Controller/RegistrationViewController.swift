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

class RegistrationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker: UIImagePickerController?
    
    
    @IBOutlet weak var nicknameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var profilePhotoView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        imagePicker = UIImagePickerController()
    }
    
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        SVProgressHUD.show()
        if let nickname = nicknameField.text, let password = passwordField.text {
            if nickname.count > 2, password.count > 5 {
                Auth.auth().createUser(withEmail: nickname, password: password) { (user, error) in
                    if let error = error {
                        SVProgressHUD.dismiss()
                        Utils.displayAlert(targetVC: self, title: "Error", message: error.localizedDescription, button: "Ok")
                        return
                    } else {
                        let thumbFolder = Storage.storage().reference().child("profilePhotos")
                        
                        if let thumbData = UIImageJPEGRepresentation(self.profilePhotoView.image!, 1) {
                            thumbFolder.child("tn_"+"\(NSUUID().uuidString).jpeg").putData(thumbData, metadata: nil, completion: { (metadata, error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                    Utils.displayAlert(targetVC: self, title: "Error", message: error.localizedDescription, button: "Ok")
                                    return
                                } else if let user = user {
                                    if let thumbURL = metadata?.downloadURL()?.absoluteString {
                                        print ("Thumbnail save to DB successfully")
                                        Database.database().reference().child("users").child(user.uid).child("email").setValue(user.email)
                                        Database.database().reference().child("users").child(user.uid).child("photoURL").setValue(thumbURL)
                                    }
                                }
                            })
                        }
                        SVProgressHUD.dismiss()
                        Utils.displayAlert(targetVC: self, title: "Congrats", message: "You have successfully created an account!", button: "Log in", segue: "goToChat")
                    }
                }
            }
        }
        
    }
    
    
    @IBAction func photoUploadPressed(_ sender: Any) {
        print("Photo pressed")
        if let picker = imagePicker {
            picker.delegate = self
            picker.sourceType = .photoLibrary
            present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let thumbnail = selectedImage.resizeImage(newWidth: CGFloat(102))
            profilePhotoView.image = thumbnail
            imagePicker?.dismiss(animated: true, completion: nil)
        }
    }
    
}
