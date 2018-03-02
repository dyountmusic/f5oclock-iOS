//
//  RedditPostDownloader.swift
//  F5OClock
//
//  Created by Daniel Yount on 3/1/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import Foundation

class RedditPostDownloader {
    
    var posts = [RedditPost]()
    var downloaded = false
    
    func downloadPosts(completion: @escaping () -> (Void)) {
        
        downloaded = false
        
        let jsonURLString = "https://www.reddit.com/r/politics/rising.json?sort=new"
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
                let redditData = try JSONDecoder().decode(RedditDataWrapper.self, from: data)
                
            } catch let jsonError {
                print("Error serializing JSON from remote server \(jsonError)")
            }
        }.resume()
    }
    
}
