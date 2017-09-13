//
//  BaseChatViewCell.swift
//  Bottle Messenger
//
//  Created by Paiste Family on 13/9/17.
//  Copyright © 2017 Bam Bam Labs. All rights reserved.
//

import UIKit

struct CellProperties {
    var userIsSender: Bool = false
    var thumbURL: URL?
    var photoURL: URL?
    var text: String = ""
    var commentCount: String = ""
    var comments: [Comment]?
    var likes: String = ""
    var likeButton: String = "Like   "
    var profilePhoto: URL?
    var senderEmail: String = ""
    var date: String = ""
    var reciever: [String]? = nil
    var hasPhoto: Bool = true
    var likeTask : (() -> Void)? = nil
    var commentTask : (() -> Void)? = nil
    var photoTask : (() -> Void)? = nil
}


