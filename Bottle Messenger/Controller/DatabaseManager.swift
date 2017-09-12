//
//  DatabaseManager.swift
//  Bottle Messenger
//
//  Created by Paiste Family on 12/9/17.
//  Copyright © 2017 Bam Bam Labs. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol DatabaseManagerDelegate {
    func initialDataRecieved (users: [User]?, messages: [Message]?)
    func messageUpdatesRecieved (messages: [Message]?)
}

class DatabaseManager {
    
    let messageDB = Database.database().reference().child("Messages")
    let usersDB = Database.database().reference().child("users")
    var messageArray : [Message] = []
    var userArray : [User] = []
    var delegate: DatabaseManagerDelegate?
    
    public func setUpFirebaseConnections() {
        
        // Get all users
        usersDB.observe(.childAdded) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                if let email = value["email"] as? String {
                    let user = User(id: snapshot.key, email: email)
                    if let photoURL = value["photoURL"] as? String {
                        user.photoURL = photoURL
                    }
                    if let nickname = value["nickname"] as? String {
                        user.nickname = nickname
                    }
                    self.userArray.append(user)
                    self.delegate?.initialDataRecieved(users: self.userArray, messages: nil)

                }
            }
        }
        
        messageDB.observe(.childAdded) { (snapshot) in
            if let valuesDictionary = snapshot.value as? Dictionary<String,Any>{
                if let sender = valuesDictionary["Sender"] as? String,
                    let text = valuesDictionary["Text"] as? String,
                    let timestamp = valuesDictionary["Date"] as? String{
                    let messageID = snapshot.key
                    let newMessage = Message(id: messageID, timestamp: timestamp, sender: sender, text: text)
                    if let reciever = valuesDictionary["Reciever"] as? [String]{
                        if reciever.count > 0 {
                            newMessage.reciever = reciever
                        }
                    }
                    if let photoURL = valuesDictionary["PhotoURL"] as? String, let thumbURL = valuesDictionary["ThumbURL"] as? String{
                        if photoURL.count > 0 {
                            newMessage.photoURL = photoURL
                            newMessage.thumbnailURL = thumbURL
                        }
                    }
                    if let likes = valuesDictionary["Likes"] as? [String]{
                        if likes.count > 0 {
                            newMessage.likes = likes
                        }
                    }
                    if let comments = valuesDictionary["Comments"] as? [String]{
                        if comments.count > 0 {
                            let commentsList = self.getComments(commentID: comments)
                            for comment in commentsList {
                                newMessage.comments?.append(comment)
                            }
                        }
                    }
                    self.messageArray.append(newMessage)
                    self.delegate?.initialDataRecieved(users: self.userArray, messages: self.messageArray)
                }
                
            }
        }
        
        messageDB.observe(.childChanged) { (snapshot) in
            if let valuesDictionary = snapshot.value as? Dictionary<String,Any>{
                let messageID = snapshot.key
                if let updatedMessage = self.messageArray.filter({ $0.id == messageID }).first {
                    
                    if let likes = valuesDictionary["Likes"] as? [String]{
                        if likes.count > 0 {
                            updatedMessage.likes = likes
                        }
                    }
                    if let comments = valuesDictionary["Comments"] as? [String]{
                        if comments.count > 0 {
                            let commentsList = self.getComments(commentID: comments)
                            updatedMessage.comments = commentsList
                        }
                    }
                    self.delegate?.messageUpdatesRecieved(messages: self.messageArray)
                }
            }
        }
        
        // TODO: Implement getComments function
        
        
    }
    
    func getComments(commentID List : [String]) -> [Comment]{
        
        
        return [Comment(text: ""),Comment(text: "")]
    }
    
    func addLike(message: Message, from: String) -> [String] {
        var likeArray = message.likes ?? []
        likeArray.append(from)
        
        messageDB.child(message.id).child("Likes").setValue(likeArray) {
            (error, reference) in
            if let error = error {
                Utils.displayAlert(targetVC: self.delegate as! UIViewController, title: "Error", message: error.localizedDescription, button: "OK")
            } else {
                print ("Like added, total likes now \(likeArray.count) for post \(message.id)")
            }
        }
        return likeArray
        
    }
    
    
    
    func removeLike(message: Message, from: String) -> [String] {
        let likeArray = message.likes ?? []
        let updatedLikeArray = likeArray.filter {$0 != from}
        
        messageDB.child(message.id).child("Likes").setValue(updatedLikeArray) {
            (error, reference) in
            if let error = error {
                if let viewController = self.delegate {
                    Utils.displayAlert(targetVC: viewController as! UIViewController, title: "Error", message: error.localizedDescription, button: "OK")
                }
            } else {
                print ("Like removed, total likes now \(updatedLikeArray.count) for post \(message.id)")
            }
        }
        return updatedLikeArray
    }
    
    func saveMessageToDatabase(userID: String,  text: String, postImageURL: String?, postThumbURL: String?) {

        var messageDict: [String:Any] = ["Sender": userID, "Reciever": [], "Text" : text,  "PhotoURL": "", "ThumbURL": "", "Date" : String(describing: Date()), "Likes": [], "Comments": []]
        
        if let imageURL = postImageURL, let thumbURL = postThumbURL {
            messageDict["PhotoURL"] = imageURL
            messageDict["ThumbURL"] = thumbURL
        }
        
        messageDB.childByAutoId().setValue(messageDict) {
            (error, reference) in
            if let error = error {
                Utils.displayAlert(targetVC: self.delegate as! UIViewController, title: "Error", message: error.localizedDescription, button: "OK")
            } else {
                
            }
        }
    }
    
    
}
