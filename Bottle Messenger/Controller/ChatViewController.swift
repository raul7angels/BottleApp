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

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ImageUploaderDelegate, DatabaseManagerDelegate, LightboxViewerDelegate {
    
    // Constants
    let userChatCellIdentifier = "rightChatCell"
    let otherChatCellIdentifier = "leftChatCell"
    let userChatXibName = "RightChatViewCell"
    let otherChatXibName = "LeftChatViewCell"
    
    
    @IBOutlet weak var textfieldHeight: NSLayoutConstraint!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var uploadedImageView: UIImageView!
    
    var keyboardHeight : CGFloat = 0
    var originalInputHeight : CGFloat = 0
    var userID = ""
    var userArray: [User] = []
    var messageArray: [Message] = []
    var postImageURL: String = ""
    var postThumbURL: String = ""
    let databaseManager = DatabaseManager()
    var lightBoxViewer = LightboxViewer()
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
        
        chatTableView.register(UINib(nibName: userChatXibName, bundle: nil), forCellReuseIdentifier: userChatCellIdentifier)
        chatTableView.register(UINib(nibName: otherChatXibName, bundle: nil), forCellReuseIdentifier: otherChatCellIdentifier)
        
        SVProgressHUD.show()
        databaseManager.getInitialData()
        configureTableView()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    // All delegate call-back functions
    
    func initialDataRecieved(users: [User]? = nil, messages: [Message]? = nil) {
        SVProgressHUD.dismiss()
        
        if let messages = messages {
            print ("Initial data recieved: Got \(messages.count) messages")
            messageArray = messages
        }
        if let users = users {
            print ("Initial data recieved: Got \(users.count) users")
            userArray = users
        }
        reloadUI()
        scrollTableToEnd()
        databaseManager.monitorForUpdates()
        
    }
    
    func addedDataRecieved(user: User?, message: Message?) {
        if let user = user {
            userArray.append(user)
            print ("Added data recieved: 1 new user added")
            databaseManager.saveMessageToDatabase(userID: user.id, text: "***WE HAVE A NEW USER***\n Please Welcome \(user.email) to the Bottle App!", postImageURL: nil, postThumbURL: nil)
            reloadUI()
        }
        if let message = message {
            messageArray.append(message)
            print ("Added data recieved: 1 new message \(message.text)")
            reloadUI()
            scrollTableToEnd()
        }
        
    }
    
    func updatedDataRecieved(user: User?, message: Message?) {
        if let user = user {
            if let updatedUser = self.userArray.filter({ $0.id == user.id }).first {
                if let index = userArray.index(of: updatedUser) {
                    userArray[index] = user
                }
            }
            reloadUI()
        }
        if let message = message {
            if let updatedMessage = self.messageArray.filter({ $0.id == message.id }).first {
                if let index = messageArray.index(of: updatedMessage) {
                    messageArray[index] = message
                    print ("Message \(message.text) was updated")
                    reloadRow(row: index)
                }
            }
        }
    }
    
    func removedDataRecieved(message: Message?) {
        if let message = message {
            
            if let deletedMessage = self.messageArray.filter({ $0.id == message.id }).first {
                if let index = messageArray.index(of: deletedMessage) {
                    messageArray.remove(at: index)
                    reloadUI()
                    print("Message removed:", message.text)
                } else {
                    print ("Can't find the message to delete")
                }
            }
        }
    }
    
    func reloadUI() {
        configureTableView()
        chatTableView.reloadData()
        //scrollTableToEnd()
    }
    
    func reloadRow(row: Int) {
        let rows = [IndexPath(row: row, section: 0)]
        chatTableView.reloadRows(at: rows, with: .automatic)
        chatTableView.layoutIfNeeded()
    }
    
    
    func photoURLReturned(photo: UIImage, thumbnail: UIImage, url: String, url_tn: String) {
        postImageURL = url
        postThumbURL = url_tn
        uploadedImageView.isHidden = false
        uploadedImageView.image = photo
    }
    
    // MARK: - Table view delegate functions
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return messageArray.count
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let selectedMessage = messageArray[indexPath.row]
        if selectedMessage.sender.id == userID {
            if editingStyle == .delete {
                print("Delete")
                databaseManager.removeMessage(message: selectedMessage)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get the info about the message from an array
        let message = messageArray[indexPath.row]
        let cellProperties = prepareCell(message: message, index: indexPath.row)
        
        // Pick cell style based on who the sender is
        var isUsersPost = false
        var cellIdentifier = otherChatCellIdentifier
        if message.sender.id == userID {
            isUsersPost = true
            cellIdentifier = userChatCellIdentifier
        }
        
        let cell = chatTableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! LeftChatViewCell
        cell.messageBoxView.backgroundColor = isUsersPost ? UIColor.flatSkyBlue() : UIColor.flatGray()
        
        cell.nicknameLabel.text = cellProperties.senderEmail
        cell.messageDateLabel.text = cellProperties.date
        cell.messageTextLabel.text = cellProperties.text
        if let profilePhoto = cellProperties.profilePhoto {cell.profilePhotoView.sd_setImage(with: profilePhoto)}
        cell.messageLikesLabel.text = cellProperties.likes
        cell.likeButton.setTitle(cellProperties.likeButton, for: .normal)
        cell.messageCommentLabel.text = cellProperties.commentCount
        if cellProperties.hasPhoto {
            cell.messagePhotoView.isHidden = false
            cell.messagePhotoView.sd_setImage(with: cellProperties.thumbURL)
        } else {
            cell.messagePhotoView.isHidden = true
            cell.messagePhotoView.image = nil
        }
        cell.commentTableView.isHidden = true
        cell.comments = message.comments
        
        cell.commentTask = {
           // UIView.animate(withDuration: 1, animations: {
                if cell.commentsOpen {
                    cell.commentTableViewHeight.constant = 10
                    //cell.commentTableViewHeight.priority = UILayoutPriority(rawValue: 250)
                    cell.commentTableView.isHidden = false
                    cell.commentsOpen = false
                } else {
                    cell.commentTableViewHeight.constant = 200
                    //cell.commentTableViewHeight.priority = UILayoutPriority(rawValue: 999)
                    cell.commentTableView.isHidden = false
                    cell.commentsOpen = true
                }
                cell.commentTableView.reloadData()
                //cell.configureTableView()
                //self.reloadRow(row: indexPath.row)
                self.reloadUI()
           // })
            

        }
        
        cell.likeTask = cellProperties.likeTask
        cell.photoTask = {
            self.lightBoxViewer.showImage(viewController: self, url: message.photoURL, backload: cell.messagePhotoView.image)
        }
        return cell
    }
    
    func prepareCell(message: Message, index: Int) -> CellProperties {
        var cellProperties = CellProperties()
        
        cellProperties.text = message.text
        
        // Make database dates look nice
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm:ss dd.MM.yyyy"
        cellProperties.date = dateformatter.string(from: message.timestamp.toDate(dateFormat: "yyyy-MM-dd HH:mm:ss ZZZ"))
        
        // Get user based on id and add e-mail & profile photo
        cellProperties.senderEmail = message.sender.email
        
        // TODO: Show number of comments
        if let comments = message.comments {
            cellProperties.commentCount = String(comments.count)
        } else {
            cellProperties.commentCount = ""
        }
        
        // Setting user profile photo
        if let photoURLString = message.sender.photoURL {
            if let photoURL = URL(string: photoURLString) {
                cellProperties.profilePhoto = photoURL
            }
        }
        
        // Check if there is a photo in the post
        if let photoURL = message.photoURL, let thumbURLString = message.thumbnailURL{
            if let thumbURL = URL(string: thumbURLString), let photoURL = URL(string: thumbURLString) {
                cellProperties.thumbURL = thumbURL
                cellProperties.photoURL = photoURL
                cellProperties.hasPhoto = true
            }
        }
        
        // Show number of likes
        var userLiked = false
        
        if let likes = message.likes {
            cellProperties.likes = likes.count == 0 ? "" : String(likes.count)
            if likes.contains(self.userID) {
                cellProperties.likeButton = "Unlike"
                userLiked = true
            } else {
                cellProperties.likeButton = "Like   "
                userLiked = false
            }
        } else {
            cellProperties.likeButton = "Like   "
            cellProperties.likes = ""
        }
        
        // Set a function for like button press
        cellProperties.likeTask = {
            if userLiked {
                self.messageArray[index].likes = self.databaseManager.removeLike(message: message, from: self.userID)
            } else {
                self.messageArray[index].likes = self.databaseManager.addLike(message: message, from: self.userID)
            }
        }
        
        // Set a function that deals with photo zoom, we know photo is there for sure otherwise user couldnt tap on it ;)
        
        
        // Function for comment button press
    return cellProperties
}



@IBAction func uploadPhotoPressed(_ sender: Any) {
    imageUploader.pickImage(viewController: self, folder: "postPhotos", tn_width: 229, width: 1080)
    textFieldDidEndEditing(chatTextField)
    uploadedImageView.isHidden = true
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
        uploadedImageView.isHidden = true
        chatTextField.isEnabled = false
        sendButton.isEnabled = false
        if let text = chatTextField.text {
            self.chatTextField.text = ""
            databaseManager.saveMessageToDatabase(userID: userID, text: text, postImageURL: postImageURL, postThumbURL: postThumbURL)
        }
    }
    self.chatTextField.isEnabled = true
    self.sendButton.isEnabled = true
    scrollTableToEnd()
}


func textFieldDidBeginEditing(_ textField: UITextField) {
    
    UIView.animate(withDuration: 1, animations: {
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.getKeyboardHeight), name: Notification.Name.UIKeyboardWillShow, object: nil)
        self.scrollTableToEnd()
    })
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
    if messageArray.count > 10 {
        chatTableView.scrollToRow(at: NSIndexPath(row: messageArray.count-1, section: 0) as IndexPath, at: .top, animated: false)
        chatTableView.scrollIndicatorInsets = chatTableView.contentInset
    }
}

}
