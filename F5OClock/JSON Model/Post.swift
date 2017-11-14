//
//  Post.swift
//  F5OClock
//
//  Created by Daniel Yount on 10/13/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import Foundation

struct Post: Codable, Hashable {
    
    let id: String
    let author: String
    let created: Int
    let title: String
    let version: Int
    let domain: String
    let url: String
    let commentLink: String
    let thumbnail: String
    let upvoteCount: Int
    let commentCount: Int
    let fetchedAt: String
	
	//MARK: Codable conformance
	
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case author = "author"
        case created = "created_utc"
        case title = "title"
        case version = "__v"
        case domain = "domain"
        case url = "url"
        case commentLink = "commentLink"
        case thumbnail = "thumbnail"
        case upvoteCount = "upvoteCount"
        case commentCount = "commentCount"
        case fetchedAt = "fetchedAt"
    }
	
	//MARK: Hashable conformance
	
	var hashValue: Int {
		return url.hashValue
	}
	
	static func ==(lhs:Post, rhs:Post) -> Bool {
		return lhs.url == rhs.url
	}
}
