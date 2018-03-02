//
//  redditURLmodel.swift
//  F5OClock
//
//  Created by Daniel Yount on 3/1/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import Foundation

struct RedditURLModel {
    
    public var redditURL: String {
        get { return UserDefaults.standard.string(forKey: "RedditURL") ?? "https://www.reddit.com/r/politics/rising.json?sort=new" }
        set { UserDefaults.standard.set(newValue, forKey: "RedditURL") }
    }
    
    mutating func generateNewRedditURL(withSubredditName: String) {
        redditURL = "https://www.reddit.com/r/\(withSubredditName)/rising.json?sort=new"
    }
    
    mutating func resetRedditURL() {
        redditURL = "https://www.reddit.com/r/politics/rising.json?sort=new"
    }
    
}
