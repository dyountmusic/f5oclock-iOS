//
//  JSONHandler.swift
//  F5OClock
//
//  Created by Daniel Yount on 10/13/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import Foundation

class JSONHandler {
    
    var posts = [Post]()
    var downloaded = false
    
    func downloadPosts() {
        
        let jsonURLString = "http://www.f5oclock.com/getPosts"
        guard let url = URL(string: jsonURLString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // TODO: Check err
            // TODO: Check for success response message 200 --> OK!
            
            print("do stuff here")
            
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
    
    
}
