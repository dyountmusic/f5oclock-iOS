//
//  JSONHandler.swift
//  F5OClock
//
//  Created by Daniel Yount on 10/13/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import Foundation

class PostDownloader {

    // MARK: Properties
    
    // These properties are used to store the fetched data for reference
    var posts = [Post]()
    var downloaded = false
    
    
    // MARK: Functions
    
    func downloadPosts() {
        
        downloaded = false
        
        let jsonURLString = "http://www.f5oclock.com/getPosts"
        guard let url = URL(string: jsonURLString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("A fatal error occured when retrieving data from the server with \(String(describing: error))")
                return
            }
            
            let status = (response as! HTTPURLResponse).statusCode
            
            if status != 200 {
                print("Status code looks a bit weird, check it out: \(status)")
                return
            }
            
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
        
        //print("Highest upvoted post is \(highestPost.title) with \(highestPost.upvoteCount) upvotes")
        return highestPost
        
    }
}
