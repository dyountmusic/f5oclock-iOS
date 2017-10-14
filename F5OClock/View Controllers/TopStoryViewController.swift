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
    
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var thumbnail: UIImageView!

    var postDownloader = PostDownloader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageActivityIndicator.isHidden = true
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
    
    // MARK: Functions
    
    func updateUI() {

        postDownloader.downloadPosts()
        
        while postDownloader.downloaded == false {
            // Waiting until the data is downloaded to execute the next line
            imageActivityIndicator.isHidden = false
            imageActivityIndicator.startAnimating()
        }
        
        imageActivityIndicator.isHidden = true
        
        downloadImage()
        titleLabel.text = postDownloader.findHighestUpvotedPost().title
        commentCountLabel.text = "\(postDownloader.findHighestUpvotedPost().commentCount) comments"
        upvoteCountLabel.text = "\(postDownloader.findHighestUpvotedPost().upvoteCount) upvotes"

    }
    
    func downloadImage() {
        
        if postDownloader.findHighestUpvotedPost().thumbnail == "default" || postDownloader.findHighestUpvotedPost().thumbnail == "self" {
            thumbnail.image = #imageLiteral(resourceName: "defaultThumbnail.png")
        }
        
        let thumbnailURL = postDownloader.findHighestUpvotedPost().thumbnail
        thumbnail.downloadedFrom(link: thumbnailURL)
        
    }
    
}

