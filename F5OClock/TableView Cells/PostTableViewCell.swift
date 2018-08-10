//
//  PostTableViewCell.swift
//  F5OClock
//
//  Created by Daniel Yount on 10/14/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import UIKit
import OAuthSwift

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var upvoteCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    
    var redditUserActionDelegate: RedditUserActionDelegate?
    
    //var redditAPIService: RedditAPIService?
    var redditPost: RedditPost?
    
    var link = ""
    var vote = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func upvoteAction(_ sender: Any) {
        guard let id = redditPost?.id else { return }
        self.redditUserActionDelegate?.upvote(id, type: "t3")
        //redditAPIService?.upvotePost(id: id, type: "t3")
    }
    
    @IBAction func downvoteAction(_ sender: Any) {
        guard let id = redditPost?.id else { return }
        self.redditUserActionDelegate?.downvote(id, type: "t3")
        //redditAPIService?.downVotePost(id: id, type: "t3")
    }
    
}
