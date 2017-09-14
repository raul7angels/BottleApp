//
//  Message.swift
//  FamilyMessenger
//
//  Created by Paiste Family on 6/9/17.
//  Copyright © 2017 Bam Bam Labs. All rights reserved.
//

import UIKit

class Message: Equatable {
    static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs === rhs
    }
    
    var id : String = ""
    var sender: User
    var reciever: [String]? = nil
    var timestamp: String = ""
    var text: String = ""
    var photoURL: String? = nil
    var thumbnailURL: String? = nil
    var likes: [String]? = []
    var comments: [Comment]? = nil
    
    init(id: String, timestamp: String, sender: User, text: String, reciever: [String]? = nil, photoURL: String? = nil, thumbnailURL: String? = nil, likes: [String]? = nil, comments: [Comment]? = nil) {
        self.id = id
        self.sender = sender
        self.reciever = reciever
        self.text = text
        self.photoURL = photoURL
        self.thumbnailURL = photoURL
        self.comments = comments
        self.likes = likes
        self.timestamp = timestamp
    }
    
}
