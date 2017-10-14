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

    
    // MARK: Properties
    
    var postDownloader = PostDownloader()
    let userDefaults = UserDefaults()
    let realTimeHandler = RealTimeRefreshHandler()
    var isRealTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageActivityIndicator.isHidden = true
        updateUI()
        
        if userDefaults.bool(forKey: "RealTimeEnabled") == true {
            realTimeHandler.startTimer(viewController: self)
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        
        if userDefaults.bool(forKey: "RealTimeEnabled") == false {
            realTimeHandler.stopTimer()
            isRealTime = false
        }
        
        if userDefaults.bool(forKey: "RealTimeEnabled") == true && isRealTime == false {
            realTimeHandler.startTimer(viewController: self)
            isRealTime = true
        }
        
        postDownloader.downloadPosts()
        
        while postDownloader.downloaded == false {
            // Waiting until the data is downloaded to execute the next line
            imageActivityIndicator.isHidden = false
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

