//
//  ChatViewCell.swift
//  FamilyMessenger
//
//  Created by Paiste Family on 6/9/17.
//  Copyright © 2017 Bam Bam Labs. All rights reserved.
//

import UIKit
import SDWebImage

class LeftChatViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
  
    // Constants
    let commentCellIdentifier = "commentCell"
    let commentCellNibName = "CommentTableViewCell"

    var comments: [Comment]?
    var likeTask : (() -> Void)? = nil
    var commentTask : (() -> Void)? = nil
    var photoTask : (() -> Void)? = nil
    var commentsOpen: Bool = false
    
    @IBOutlet weak var messageBoxView: UIView!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var messageCommentLabel: UILabel!
    @IBOutlet weak var commentTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var messageLikesLabel: UILabel!
    @IBOutlet weak var messagePhotoView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messagePhotoView.isHidden = true
        self.selectionStyle = UITableViewCellSelectionStyle.none
        // Add photo Tap gesture recognizer
        messagePhotoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoTapped)))
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.isScrollEnabled = true
        commentTableView.isHidden = commentsOpen ? false : true
        commentTableView.register(UINib(nibName: commentCellNibName, bundle: nil), forCellReuseIdentifier: commentCellIdentifier)
        configureTableView()
        
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let comments = comments {
        print ("Have \(comments.count) comments")
            return comments.count
        }
        return 0
    }
    
    func configureTableView() {
        commentTableView.rowHeight = UITableViewAutomaticDimension
        commentTableView.estimatedRowHeight = 200
        commentTableView.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = commentTableView.dequeueReusableCell(withIdentifier: commentCellIdentifier) as! CommentTableViewCell
        if let comments = comments {
            let comment = comments[indexPath.row]
            print("Made a comment \(comment.text)cell for message\(messageTextLabel.text)")
            cell.commentTextLabel.text = comment.text
            cell.senderLabel.text = comment.sender.email
            cell.dateLabel.text = comment.date
            if let profilePhotoURL = comment.sender.photoURL {
                cell.profilePhotoView.sd_setImage(with: URL(string:profilePhotoURL), completed: nil)
            }
        }
        
        return cell
    }
    
    @objc func photoTapped() {
        print("Photo tapped")
        if let btnAction = self.photoTask
        {
            btnAction()
        }
    }
    
    @IBAction func likeTapped(_ sender: Any) {
        print("Like tapped \(String(describing: self.likeTask))")
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
