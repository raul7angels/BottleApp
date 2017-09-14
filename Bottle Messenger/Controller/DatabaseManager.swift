//
//  DatabaseManager.swift
//  Bottle Messenger
//
//  Created by Paiste Family on 12/9/17.
//  Copyright © 2017 Bam Bam Labs. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SDWebImage

protocol DatabaseManagerDelegate {
    func initialDataRecieved (users: [User]?, messages: [Message]?)
    func addedDataRecieved (user: User?, message:  Message? )
    func updatedDataRecieved (user: User?, message: Message?)
    func removedDataRecieved (message: Message?)

}

class DatabaseManager {
    
    let messageDB = Database.database().reference().child("Messages")
    let usersDB = Database.database().reference().child("users")
    var messageArray : [Message] = []
    var userArray : [User] = []
    var delegate: DatabaseManagerDelegate?
    var imageManager = SDWebImagePrefetcher()
    
    func mapUserData(snapshot: DataSnapshot) -> User {
        var user = User(id: "", email: "")
        if let value = snapshot.value as? [String : AnyObject] {
            if let email = value["email"] as? String {
                let newUser = User(id: snapshot.key, email: email)
                if let photoURL = value["photoURL"] as? String {
                    newUser.photoURL = photoURL
                    if let  url = URL(string: photoURL) {
                        print("Pre-Loading image for user:", newUser.email)
                        self.imageManager.prefetchURLs([url], progress: nil, completed: { (completed, skipped) in
                            print("Pre-Loading image for user:", newUser.email)
                            print ("Completed \(completed), Skipped \(skipped)")
                        })
                    }
                }
                if let nickname = value["nickname"] as? String {
                    newUser.nickname = nickname
                }
                user = newUser
            }
        }
        // print("User:", user.email)
        
        return user
    }
    
    func mapMessageData(snapshot: DataSnapshot) -> Message {
        var message = Message(id: "", timestamp: "", sender: User(id: "", email: ""), text: "")
        if let value = snapshot.value as? [String : AnyObject] {
            if let senderID = value["Sender"] as? String,
                let text = value["Text"] as? String,
                let timestamp = value["Date"] as? String{
                let messageID = snapshot.key
                if let sender = self.userArray.filter({ $0.id == senderID }).first {
                    let newMessage = Message(id: messageID, timestamp: timestamp, sender: sender, text: text)
                    if let reciever = value["Reciever"] as? [String], reciever.count > 0 {
                        newMessage.reciever = reciever
                    }
                    if let photoURL = value["PhotoURL"] as? String, let thumbURL = value["ThumbURL"] as? String, photoURL.count > 0 {
                        newMessage.photoURL = photoURL
                        newMessage.thumbnailURL = thumbURL
                        if let url = URL(string: photoURL), let tn_url = URL(string: thumbURL) {
                            self.imageManager.prefetchURLs([url, tn_url], progress: nil, completed: { (completed, skipped) in
                                print("Pre-Loading image for message:", newMessage.text)
                                print ("Completed \(completed), Skipped \(skipped)")
                            })
                        }
                    }
                    if let likes = value["Likes"] as? [String], likes.count > 0{
                        newMessage.likes = likes
                    }
                    if let comments = value["Comments"] as? [String], comments.count > 0{
                        for comment in self.getComments(commentID: comments) {
                            newMessage.comments?.append(comment)
                        }
                    }
                    message = newMessage
                }
            }
        }
        return message
    }
    
    func getInitialData() {
        // Get all existing users and messages
        
        usersDB.observeSingleEvent(of: .value) { (snapshot) in
            for user in snapshot.children {
                self.userArray.append(self.mapUserData(snapshot: user as! DataSnapshot))
            }
        }
        
        messageDB.observeSingleEvent(of: .value) { (snapshot) in
            for message in snapshot.children {
                self.messageArray.append(self.mapMessageData(snapshot: message as! DataSnapshot))
            }
            self.delegate?.initialDataRecieved(users: self.userArray, messages: self.messageArray)
        }
    }
    
    func monitorForUpdates() {
        
        // Get new users and messages that are not already in the array
        usersDB.observe(.childAdded) { (snapshot) in
            let user = self.mapUserData(snapshot: snapshot)
            guard let _ = self.userArray.filter({ $0.id == user.id }).first else {
                self.userArray.append(user)
                self.delegate?.addedDataRecieved(user: user, message: nil)
                return
            }
        }
        
        messageDB.observe(.childAdded) { (snapshot) in
            let message = self.mapMessageData(snapshot: snapshot)
            guard let _ = self.messageArray.filter({ $0.id == message.id }).first else {
                self.messageArray.append(message)
                self.delegate?.addedDataRecieved(user: nil, message: message)
                return
            }
        }
        
        messageDB.observe(.childRemoved) { (snapshot) in
            print ("Something was removed", snapshot.key)
            let message = self.mapMessageData(snapshot: snapshot)
            self.delegate?.removedDataRecieved(message: message)
        }

        
        // Get chages done to existing records
        usersDB.observe(.childChanged) { (snapshot) in
            let user = self.mapUserData(snapshot: snapshot)
            if let updatedUser = self.userArray.filter({ $0.id == user.id }).first {
                self.delegate?.updatedDataRecieved(user: updatedUser, message: nil)
            }
        }
        
        messageDB.observe(.childChanged) { (snapshot) in
            let message = self.mapMessageData(snapshot: snapshot)
            if let updatedMessage = self.messageArray.filter({ $0.id == message.id }).first {
                self.delegate?.updatedDataRecieved(user: nil, message: updatedMessage)
            }
        }
        
        // TODO: Implement getComments function
        
        
    }
    
    func getComments(commentID List : [String]) -> [Comment]{
        
        
        return []
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
    
    func removeMessage (message: Message) {
        
        messageDB.child(message.id).removeValue()
        if let index = messageArray.index(of: message) {
            messageArray.remove(at: index )
        }

        }
    
    
}
