//
//  ChatViewCell.swift
//  FamilyMessenger
//
//  Created by Paiste Family on 6/9/17.
//  Copyright © 2017 Bam Bam Labs. All rights reserved.
//

import UIKit

class ChatViewCell: UITableViewCell {

    var likeTask : (() -> Void)? = nil
    var commentTask : (() -> Void)? = nil
    var photoTask : (() -> Void)? = nil

    
    @IBOutlet weak var messageBoxView: UIView!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var messageCommentLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var messageLikesLabel: UILabel!
    @IBOutlet weak var messagePhotoView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messagePhotoView.isHidden = true
        self.selectionStyle = UITableViewCellSelectionStyle.none
        // Add photo Tap gesture recognizer
        messagePhotoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoTapped)))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func photoTapped() {
        print("Photo tapped")
        if let btnAction = self.photoTask
        {
            btnAction()
        }
    }
    
    @IBAction func likeTapped(_ sender: Any) {
        print("Like tapped")
        if let btnAction = self.likeTask
        {
            btnAction()
        }
    }
    
    @IBAction func commentTapped(_ sender: Any) {
        print("Comment tapped")
        if let btnAction = self.commentTask
        {
            btnAction()
        }
    }
    
}
