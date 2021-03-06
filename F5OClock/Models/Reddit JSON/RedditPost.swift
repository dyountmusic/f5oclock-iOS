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
    let type: String
    let data: RedditPost
    
    enum CodingKeys: String, CodingKey {
        case type = "kind"
        case data = "data"
    }
}

struct RedditPost: Codable, Hashable {
    
    let title: String
    let upvotes: Int
    let url: String
    let thumbnail: String
    let commentCount: Int
    
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case upvotes = "ups"
        case url = "url"
        case thumbnail = "thumbnail"
        case commentCount = "num_comments"
        case id = "id"
    }
    
    var hashValue: Int {
        return title.hashValue
    }
    
    static func ==(lhs: RedditPost, rhs: RedditPost) -> Bool {
        return lhs.title == rhs.title
    }
    
}
