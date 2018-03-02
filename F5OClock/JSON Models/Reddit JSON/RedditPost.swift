//
//  PostRedditAPI.swift
//  F5OClock
//
//  Created by Daniel Yount on 3/1/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import Foundation

struct RedditDataWrapper: Codable {
    
    let kind: String
    let data: RedditData
    
}

struct RedditData: Codable {
    
    let numOfPosts: Int
    let posts: [RedditPosts]
    
    enum CodingKeys: String, CodingKey {
        case numOfPosts = "dist"
        case posts = "children"
    }
    
}

struct RedditPosts: Codable {
    let data: RedditPost
}

struct RedditPost: Codable {
    
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
