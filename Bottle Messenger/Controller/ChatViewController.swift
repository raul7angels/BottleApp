//
//  ChatViewController.swift
//  FamilyMessenger
//
//  Created by Paiste Family on 6/9/17.
//  Copyright © 2017 Bam Bam Labs. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage
import ChameleonFramework
import BFRImageViewer
import SVProgressHUD

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ImageUploaderDelegate, DatabaseManagerDelegate {
    
    @IBOutlet weak var textfieldHeight: NSLayoutConstraint!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    var keyboardHeight : CGFloat = 0
    var originalInputHeight : CGFloat = 0
    var userID = ""
    var userArray: [User] = []
    var messageArray: [Message] = []
    var postImageURL: String = ""
    var postThumbURL: String = ""
    let databaseManager = DatabaseManager()
    var imageUploader: ImageUploader = ImageUploader()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up all delegates and satassources
        databaseManager.delegate = self
        imageUploader.delegate = self
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTextField.delegate = self
        
        originalInputHeight = textfieldHeight.constant
        if let id = Auth.auth().currentUser?.uid {
            userID = id
        } else {
            Utils.displayAlert(targetVC: self, title: "Error", message: "Please log in to use the bottle chat.", button: "Log in", segue: "goToLogin")
        }
        
        chatTableView.register(UINib(nibName: "ChatViewCell", bundle: nil), forCellReuseIdentifier: "chatCell")
        
        SVProgressHUD.show()
        databaseManager.setUpFirebaseConnections()
        configureTableView()

    }
    
    // All delegate call-back functions
    
    func initialDataRecieved(users: [User]? = nil, messages: [Message]? = nil) {
        SVProgressHUD.dismiss()

        if let messages = messages {
            print ("Got \(messages.count) messages")
            messageArray = messages
        }
        if let users = users {
        print ("Got \(users.count) users")
        userArray = users
        }
        reloadUI()

        
    }
    
    func messageUpdatesRecieved(messages: [Message]? = nil) {
        if let messages = messages {
            messageArray = messages
            reloadUI()
        }
    }
    
    func reloadUI() {
        configureTableView()
        chatTableView.reloadData()
        //scrollTableToEnd()
    }
    
    func photoURLReturned(photo: UIImage, thumbnail: UIImage, url: String, url_tn: String) {
        postImageURL = url
        postThumbURL = url_tn
    }
    
    // MARK: - Table view delegate functions

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        return messageArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = chatTableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatViewCell
        
        let message = messageArray[indexPath.row]
        cell.messageTextLabel.text = message.text
        
        let date = message.timestamp.toDate(dateFormat: "yyyy-MM-dd HH:mm:ss ZZZ")
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm:ss dd.MM.yyyy"
        let dateString = dateformatter.string(from: date)
        
        // Get user and add e-mail, photos, likes and comments
        if let sender = userArray.filter({ $0.id == message.sender }).first {
            cell.nicknameLabel.text = sender.email
            cell.messageDateLabel.text = String(dateString)
            
            // Setting user profile photo
            if let photoURLString = sender.photoURL {
                if let photoURL = URL(string: photoURLString) {
                    cell.profilePhotoView.sd_setImage(with: photoURL)
                }
            }
            
            // Setting photo inside post

            if let _ = message.photoURL, let thumbURLString = message.thumbnailURL{
                if let thumbURL = URL(string: thumbURLString) {
                    cell.messagePhotoView.isHidden = false
                    cell.messagePhotoView.sd_setImage(with: thumbURL)
                }
            } else {
                cell.messagePhotoView.isHidden = true
                cell.messagePhotoView.image = nil
            }
            
            // Show number of likes
            var userLiked = false
            
            if let likes = message.likes {
                cell.messageLikesLabel.text = likes.count == 0 ? "" : String(likes.count)
                
                // Check if user has liked the message
                if likes.contains(self.userID) {
                    cell.likeButton.setTitle("Unlike", for: UIControlState.normal)
                    userLiked = true
                } else {
                    cell.likeButton.setTitle("Like   ", for: UIControlState.normal)
                    userLiked = false
                }
                
            } else {
                cell.likeButton.setTitle("Like   ", for: UIControlState.normal)
                cell.messageLikesLabel.text = ""
            }
            
            // Function for like button press
            cell.likeTask = {
                if userLiked {
                    message.likes = self.databaseManager.removeLike(message: message, from: self.userID)
                } else {
                    message.likes = self.databaseManager.addLike(message: message, from: self.userID)
                }
                self.chatTableView.reloadData()
            }
            
            // Function that deals with photo zoom

            cell.photoTask = {
                LightboxViewer.showImage(viewController: self, url: message.photoURL, backload: cell.messagePhotoView.image)
            }
            
            
            // TODO: Show number of comments
            if let comments = message.comments {
                cell.messageCommentLabel.text = String(comments.count)
            } else {
                cell.messageCommentLabel.text = ""
            }
            
            // Function for comment button press
            cell.commentTask = {
                print("It works, unbelievable \(sender.email)")
            }
        
        }
        
        // Add some color
        if message.sender == userID {
            cell.messageBoxView.backgroundColor = UIColor.flatSkyBlue()
        } else {
            cell.messageBoxView.backgroundColor = UIColor.flatGray()
        }
        return cell
    }
    
    
    @IBAction func uploadPhotoPressed(_ sender: Any) {
        imageUploader.pickImage(viewController: self, folder: "postPhotos", tn_width: 229, width: 1080)
        textFieldDidEndEditing(chatTextField)
    }
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        try? Auth.auth().signOut()
        performSegue(withIdentifier: "goToLogin", sender: nil)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 1, animations: {
            self.view.endEditing(true)
            self.textfieldHeight.constant = self.originalInputHeight
            self.view.layoutIfNeeded()
        })
    }
    
    
    func configureTableView() {
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.estimatedRowHeight = 120
        view.layoutIfNeeded()
    }
    
    
    @IBAction func tableViewTapped(_ sender: Any) {
        textFieldDidEndEditing(chatTextField)
    }

    
    @IBAction func sendPressed(_ sender: Any) {
        if chatTextField.text != "" {
            textFieldDidEndEditing(chatTextField)
            chatTextField.isEnabled = false
            sendButton.isEnabled = false
            self.chatTextField.text = ""
            
            if let text = chatTextField.text {
                databaseManager.saveMessageToDatabase(userID: userID, text: text, postImageURL: postImageURL, postThumbURL: postThumbURL)
            }
        }
        self.chatTextField.isEnabled = true
        self.sendButton.isEnabled = true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 1, animations: {
            NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.getKeyboardHeight), name: Notification.Name.UIKeyboardWillShow, object: nil)
        })
    }
    
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    
    @objc func getKeyboardHeight(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = CGFloat(keyboardSize.height)
            textfieldHeight.constant = originalInputHeight + keyboardHeight
            scrollTableToEnd()
            view.layoutIfNeeded()
            print("Keyboard height is: \(keyboardHeight)")
        }
    }
    
    public func scrollTableToEnd() {
        chatTableView.scrollToRow(at: NSIndexPath(row: messageArray.count-1, section: 0) as IndexPath, at: .top, animated: false)
        chatTableView.scrollIndicatorInsets = chatTableView.contentInset
    }
    
}
