//
//  User.swift
//  Bottle Messenger
//
//  Created by Paiste Family on 7/9/17.
//  Copyright © 2017 Bam Bam Labs. All rights reserved.
//

import Foundation
import UIKit

class User: Equatable {
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs === rhs
    }
    
    var id: String = ""
    var email: String = ""
    var nickname: String?
    var photoURL: String?
    var fullSizePhotoURL: String?

    init (id: String, email: String, nickname: String? = nil, photoURL: String? = nil, fullSizePhotoURL: String? = nil){
        self.id = id
        self.email = email
        self.nickname = nickname
        self.photoURL = photoURL
        self.fullSizePhotoURL = fullSizePhotoURL
    }
}
