//
//  PostRedditAPI.swift
//  F5OClock
//
//  Created by Daniel Yount on 3/1/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import Foundation

struct RedditData {
    
    let children: [RedditChildren]
    
}

struct RedditChildren {
    
    let data: [RedditPost]
    
}

struct RedditPost {
    
    let title: String
    let upvotes: Int
    let url: String
    let thumbnail: String
    
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case upvotes = "ups"
        case url = "url"
        case thumbnail = "thumbnail"
    }
    
}
