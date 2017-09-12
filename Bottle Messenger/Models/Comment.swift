//
//  Comment.swift
//  Bottle Messenger
//
//  Created by Paiste Family on 6/9/17.
//  Copyright © 2017 Bam Bam Labs. All rights reserved.
//

import Foundation

class Comment {
    var id: String = ""
    var sender: String = ""
    var text: String = ""
    var likes : [String] = []
    weak var message: Message?
    
    init(text: String){
        self.text = text
    }
}
