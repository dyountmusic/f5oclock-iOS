//
//  F5OClockTests.swift
//  F5OClockTests
//
//  Created by Daniel Yount on 10/13/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import XCTest
@testable import F5OClock

class PostTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
    }
    
    func testFindHighestUpvotedPost() {
        // Mocked Post objects
        
        let highestPost = RedditPost(title: "Highest Post", upvotes: 2, url: "", thumbnail: "", commentCount: 0)
        let lowestPost = RedditPost(title: "Lowest Post", upvotes: 1, url: "", thumbnail: "", commentCount: 0)
        let negativePost = RedditPost(title: "", upvotes: -1, url: "", thumbnail: "", commentCount: 0)
        
        // Create the post downloader object
        let postDownloader = RedditPostDownloader()
        postDownloader.posts = [highestPost, lowestPost]
        
        // Calculate expected result
        postDownloader.sortPosts()
        guard let result = postDownloader.posts.first else {
            XCTFail()
            return
        }
        
        // Check equality of expected result
        XCTAssertEqual(result.upvotes, highestPost.upvotes)
        XCTAssertEqual(result.title, "Highest Post")
        XCTAssertNotEqual(result.upvotes, lowestPost.upvotes)
        XCTAssertNotEqual(result.title, "Lowest Post")
        
        // Run Negative Test
        postDownloader.posts = [highestPost, negativePost]
        postDownloader.sortPosts()
        guard let result2 = postDownloader.posts.first else {
            XCTFail()
            return
        }
        
        // Check equality of expected result
        XCTAssertEqual(result2.upvotes, highestPost.upvotes)
        XCTAssertEqual(result2.title, "Highest Post")
        XCTAssertNotEqual(result2.upvotes, negativePost.upvotes)
        XCTAssertNotEqual(result2.title, "Lowest Post")
        
        // Run Test on Same Post
        postDownloader.posts = [highestPost, highestPost]
        postDownloader.sortPosts()
        guard let result3 = postDownloader.posts.first else {
            XCTFail()
            return
        }
        
        // Check equality of expected result
        XCTAssertEqual(result3.upvotes, 2)
        XCTAssertNotEqual(result3.upvotes, 1)
        
    }
	
	func testNoPostsDuplicated() {
		// Mocked Post objects
        let postA = RedditPost(title: "Post A", upvotes: 10, url: "http://www.aaa.com/a/", thumbnail: "", commentCount: 0)
        let postB = RedditPost(title: "Post B", upvotes: 9, url: "bbb.com/", thumbnail: "", commentCount: 0)
        let postB2 = RedditPost(title: "Post B", upvotes: 3, url: "bbb.com/", thumbnail: "", commentCount: 0)
        let postC = RedditPost(title: "Post C", upvotes: -1, url: "ccc.com/", thumbnail: "", commentCount: 0)
        let postC2 = RedditPost(title: "Post C", upvotes: 7, url: "ccc.com/?something=v", thumbnail: "", commentCount: 0)

		// Create the post downloader object
		let postDownloader = RedditPostDownloader()
		postDownloader.posts = [postA, postB, postB2, postC, postC2]
		
		// Calculate expected result
		postDownloader.sortPosts()
		postDownloader.removeDuplicates()
		
		// Test Equatable (Hashable) extension
		XCTAssertEqual(postB, postB2)
		XCTAssertEqual(postC, postC2)
		
		// Make sure there are only 3 posts after removing duplicates
		XCTAssertTrue(postDownloader.posts.count == 3)
		XCTAssertTrue(postDownloader.posts[0] == postA)
		// Make sure the higher upvoted post B is chosen (!assuming presorted!)
		XCTAssertTrue(postDownloader.posts[1] == postB && postDownloader.posts[1].title == "Post B")
		// Make sure the higher upvoted post C is chosen
		XCTAssertTrue(postDownloader.posts[2] == postC2)
	}

    
    func testResponseFromServer() {
        
        let postDownloader = RedditPostDownloader()
        
		postDownloader.downloadPosts() {
			XCTAssertNotNil(postDownloader)
			XCTAssertNotNil(postDownloader.posts[0].title)
		}
        
    }
    
}
