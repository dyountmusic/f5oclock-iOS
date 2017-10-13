//
//  ViewController.swift
//  F5OClock
//
//  Created by Daniel Yount on 10/13/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import UIKit

class TopStoryViewController: UIViewController {
    
    //MARK: Interface Builder Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var upvoteCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var highestPostText: UILabel!
    
    @IBOutlet weak var thumbnail: UIImageView!

    var postDownloader = PostDownloader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Interface Builder Actions
    
    @IBAction func refreshTopStory(_ sender: Any) {
        updateUI()
        
    }
    
    @IBAction func findHighestUpvotedPost(_ sender: Any) {
        let highestPost = postDownloader.findHighestUpvotedPost()
        self.highestPostText.text = "Highest upvoted post is \(highestPost.title) with \(highestPost.upvoteCount) upvotes"
    }
    
    // MARK: Functions
    
    func updateUI() {
        
        postDownloader.downloaded = false
        postDownloader.downloadPosts()
        downloadImage()
        
        while postDownloader.downloaded == false {
            while postDownloader.posts.first?.title == nil {
                titleLabel.text = postDownloader.posts.first?.title
                downloadImage()
            }
            titleLabel.text = postDownloader.posts.first?.title
            upvoteCountLabel.text = "\(postDownloader.posts.first?.upvoteCount ?? 0) upvotes"
            commentCountLabel.text = "\(postDownloader.posts.first?.commentCount ?? 0) comments"
        }
    }
    
    func downloadImage() {
        
        if postDownloader.posts.first?.thumbnail == "default" || postDownloader.posts.first?.thumbnail == "self" {
            thumbnail.image = #imageLiteral(resourceName: "defaultThumbnail.png")
        }
        
        guard let thumbnailURL = postDownloader.posts.first?.thumbnail else { return }
        thumbnail.downloadedFrom(link: thumbnailURL)
        
    }
    
}

