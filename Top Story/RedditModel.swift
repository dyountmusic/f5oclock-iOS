//
//  redditURLmodel.swift
//  F5OClock
//
//  Created by Daniel Yount on 3/1/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import Foundation

class RedditModel {
    
    public var subredditName: String {
        get { return UserDefaults.init(suiteName: "group.TopStoriesExtensionSharingDefaults")?.string(forKey: "SubredditName") ?? "Politics" }
        set { UserDefaults.standard.set(newValue, forKey: "SubredditName")
            UserDefaults.init(suiteName: "group.TopStoriesExtensionSharingDefaults")?.set(newValue, forKey: "SubredditName")
            redditURL = "https://www.reddit.com/r/\(newValue)/rising.json?sort=new"
        }
    }
    
    public var redditURL: String {
        get { return UserDefaults.init(suiteName: "group.TopStoriesExtensionSharingDefaults")?.string(forKey: "RedditURL") ?? "https://www.reddit.com/r/politics/rising.json?sort=new" }
        set { UserDefaults.init(suiteName: "group.TopStoriesExtensionSharingDefaults")?.set(newValue, forKey: "RedditURL")
            print("Setting redditURL to: \(newValue)")
        }
    }
    
    func resetRedditURL() {
        redditURL = "https://www.reddit.com/r/politics/rising.json?sort=new"
        subredditName = "Politics"
    }
    
}

