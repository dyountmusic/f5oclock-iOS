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

struct RedditPost: Codable, Hashable {
    
    let title: String
    let upvotes: Int
    let url: String
    let thumbnail: String
    let commentCount: Int
    
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case upvotes = "ups"
        case url = "url"
        case thumbnail = "thumbnail"
        case commentCount = "num_comments"
    }
    
    var hashValue: Int {
        return title.hashValue
    }
    
    static func ==(lhs: RedditPost, rhs: RedditPost) -> Bool {
        return lhs.title == rhs.title
    }
    
}

