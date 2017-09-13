//
//  ImageUploader.swift
//  Bottle Messenger
//
//  Created by Paiste Family on 10/9/17.
//  Copyright © 2017 Bam Bam Labs. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import SVProgressHUD
import SDWebImage

extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

protocol ImageUploaderDelegate {
    func photoURLReturned (photo: UIImage, thumbnail: UIImage, url: String, url_tn: String)
}

class ImageUploader: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var storageFolder: String = ""
    var thumbnailWidth: Int = 100
    var imageWidth: Int?
    var thumbnailURL: String = ""
    var imageURL: String = ""
    var delegate: ImageUploaderDelegate?
    var imagePicker: UIImagePickerController?
    var parentVC = UIViewController()
    var imageManager = SDWebImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func pickImage(viewController: UIViewController, folder: String, tn_width: Int, width: Int) {
        print ("pickImage got called ")
        imagePicker = UIImagePickerController()
        
        if let picker = imagePicker {
            picker.delegate = self
            picker.sourceType = .photoLibrary
            storageFolder = folder
            thumbnailWidth = tn_width
            imageWidth = width
            parentVC = viewController
            
            // Display Image picker in destination ViewController
            viewController.present(picker, animated: true, completion: nil)
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        SVProgressHUD.show()
        // Check if we got the image
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePicker?.dismiss(animated: true, completion: nil)
            
            // Resize if required and create a thumbnail
            var thumbnail = selectedImage
            var image = selectedImage

            if Int(selectedImage.size.width) > thumbnailWidth {
                thumbnail = selectedImage.resizeImage(newWidth: CGFloat(thumbnailWidth))
            }
            
            if let imageWidth = imageWidth {
                if Int(selectedImage.size.width) > imageWidth {
                    image = selectedImage.resizeImage(newWidth: CGFloat(imageWidth))
                }
            }
            
            
            let workingFolder = Storage.storage().reference().child(storageFolder)
            
            // Convert the images to binary data
            if let imageData = UIImageJPEGRepresentation(image, 1), let thumbData = UIImageJPEGRepresentation(thumbnail, 1) {
                
                // Write images to Firebase Storage folder with unique filename
                workingFolder.child("\(NSUUID().uuidString).jpeg").putData(imageData, metadata: nil, completion: { (metadata, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        Utils.displayAlert(targetVC: self, title: "Error", message: error.localizedDescription, button: "Ok")
                        return
                    } else {
                        if let imgURLString = metadata?.downloadURL()?.absoluteString {
                            self.imageURL = imgURLString
                            self.imageManager.saveImage(toCache: image, for: URL(string:imgURLString))
                            workingFolder.child("thumbnails/tn_\(NSUUID().uuidString).jpeg").putData(thumbData, metadata: nil, completion: { (metadata, error) in
                                if let error = error {
                                    SVProgressHUD.dismiss()
                                    Utils.displayAlert(targetVC: self, message: error.localizedDescription)
                                }
                                if let imgURLString = metadata?.downloadURL()?.absoluteString {
                                    self.thumbnailURL = imgURLString
                                    self.imageManager.saveImage(toCache: thumbnail, for: URL(string:imgURLString))
                                    // Once finished call delegate function with UIImages + image URL-s
                                    self.delegate?.photoURLReturned(photo: image, thumbnail: thumbnail, url: self.imageURL, url_tn: self.thumbnailURL)
                                    SVProgressHUD.dismiss()
                                }
                            })
                            
                        }
                    }
                })
            }
            
        }
    }
}
