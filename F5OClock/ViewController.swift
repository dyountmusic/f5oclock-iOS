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
    
    //MARK: Properties
    var posts = [Post]()
    let jsonURLString = "http://www.f5oclock.com/getPosts"
    var downloaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadPosts()
        
        while downloaded == false {
            titleLabel.text = "Article: \(posts.first?.title)"
            upvoteCountLabel.text = "\(posts.first?.upvoteCount ?? 0) upvotes"
            commentCountLabel.text = "\(posts.first?.commentCount ?? 0) comments"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadPosts() {
        
        guard let url = URL(string: jsonURLString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // TODO: Check err
            // TODO: Check for success response message 200 --> OK!
            
            print("do stuff here")
            
            guard let data = data else { return }
            
            do {
                let downloadedPosts = try JSONDecoder().decode([Post].self, from: data)
                
                self.posts = downloadedPosts
                
                
                print("There are \(downloadedPosts.count) posts")
                print("Upvote count for \(downloadedPosts.first?.title) is \(downloadedPosts.first?.upvoteCount) with \(downloadedPosts.first?.commentCount) comments")
                
                self.downloaded = true
                
            } catch let jsonError {
                print("Error serializing JSON from remote server \(jsonError)")
            }
            
            }.resume()
        
    }
    
    
}

