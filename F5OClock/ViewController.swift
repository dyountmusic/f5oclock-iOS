//
//  ViewController.swift
//  F5OClock
//
//  Created by Daniel Yount on 10/13/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: IBProperties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var upvoteCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var highestPostText: UILabel!
    
    @IBOutlet weak var thumbnail: UIImageView!

    //MARK: Properties
    var posts = [Post]()
    var downloaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshTopStory(_ sender: Any) {
        updateUI()
        
    }
    @IBAction func findHighestUpvotedPost(_ sender: Any) {
        var highestPost = findHighestUpvotedPost()
        self.highestPostText.text = "Highest upvoted post is \(highestPost.title) with \(highestPost.upvoteCount) upvotes"
    }
    
    func updateUI() {
        
        downloaded = false
        
        downloadPosts()
        downloadImage()
        
        while downloaded == false {
            while posts.first?.title == nil {
                //print("Title is \(posts.first?.title)")
                titleLabel.text = posts.first?.title
                downloadImage()
            }
            titleLabel.text = posts.first?.title
            upvoteCountLabel.text = "\(posts.first?.upvoteCount ?? 0) upvotes"
            commentCountLabel.text = "\(posts.first?.commentCount ?? 0) comments"
        }
    }
    
    func downloadImage() {
        
        if posts.first?.thumbnail == "default" || posts.first?.thumbnail == "self" {
            thumbnail.image = #imageLiteral(resourceName: "defaultThumbnail.png")
        }
        
        guard let thumbnailURL = posts.first?.thumbnail else { return }
        thumbnail.downloadedFrom(link: thumbnailURL)
        
    }
    
    func downloadPosts() {
        
        let jsonURLString = "http://www.f5oclock.com/getPosts"
        guard let url = URL(string: jsonURLString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // TODO: Check err
            // TODO: Check for success response message 200 --> OK!
            
            guard let data = data else { return }
            
            do {
                
                let downloadedPosts = try JSONDecoder().decode([Post].self, from: data)
                self.posts = downloadedPosts
                self.downloaded = true
                
            } catch let jsonError {
                print("Error serializing JSON from remote server \(jsonError)")
            }
            
            }.resume()
    }
    
    func findHighestUpvotedPost() -> Post {
        
        guard let firstValue = posts.first else {
            print("Found nil in first value of posts array. Aborting sort method.")
            return Post(id: "Not found", author: "Not found", created: 0, title: "Not found", version: 1, domain: "Not Found", url: "Not found", commentLink: "Not found", thumbnail: "Not found", upvoteCount: 1, commentCount: 1, fetchedAt: "Not found")
        }
        
        var highestPost = firstValue
        
        for p in posts {
            
            if p.upvoteCount > highestPost.upvoteCount {
                highestPost = p
            }
        }
        
        print("Highest upvoted post is \(highestPost.title) with \(highestPost.upvoteCount) upvotes")
        return highestPost
        
    }
    
}

