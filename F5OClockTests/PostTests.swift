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
        let highestPost = Post(id: "", author: "", created: 0, title: "Highest Post", version: 0, domain: "", url: "high.com", commentLink: "", thumbnail: "", upvoteCount: 2, commentCount: 0, fetchedAt: "")
        let lowestPost =  Post(id: "", author: "", created: 0, title: "Lowest Post", version: 0, domain: "", url: "low.com", commentLink: "", thumbnail: "", upvoteCount: 1, commentCount: 0, fetchedAt: "")
        let negativePost = Post(id: "", author: "", created: 0, title: "Negative Post", version: 0, domain: "", url: "neg.com", commentLink: "", thumbnail: "", upvoteCount: -1, commentCount: 0, fetchedAt: "")
        
        // Create the post downloader object
        let postDownloader = PostDownloader()
        postDownloader.posts = [highestPost, lowestPost]
        
        // Calculate expected result
        let result = postDownloader.findHighestUpvotedPost()
        
        // Check equality of expected result
        XCTAssertEqual(result.upvoteCount, highestPost.upvoteCount)
        XCTAssertEqual(result.title, "Highest Post")
        XCTAssertNotEqual(result.upvoteCount, lowestPost.upvoteCount)
        XCTAssertNotEqual(result.title, "Lowest Post")
        
        // Run Negative Test
        postDownloader.posts = [highestPost, negativePost]
        let result2 = postDownloader.findHighestUpvotedPost()
        
        // Check equality of expected result
        XCTAssertEqual(result2.upvoteCount, highestPost.upvoteCount)
        XCTAssertEqual(result2.title, "Highest Post")
        XCTAssertNotEqual(result2.upvoteCount, negativePost.upvoteCount)
        XCTAssertNotEqual(result2.title, "Lowest Post")
        
        // Run Test on Same Post
        postDownloader.posts = [highestPost, highestPost]
        let result3 = postDownloader.findHighestUpvotedPost()
        
        // Check equality of expected result
        XCTAssertEqual(result3.upvoteCount, 2)
        XCTAssertNotEqual(result3.upvoteCount, 1)
        
    }
	
	func testNoPostsDuplicated() {
		// Mocked Post objects
		let postA  = Post(id: "", author: "a1", created: 0, title: "Post A", version: 0, domain: "", url: "aaa", commentLink: "", thumbnail: "", upvoteCount: 10, commentCount: 0, fetchedAt: "")
		let postB  = Post(id: "", author: "b1", created: 0, title: "Post B", version: 0, domain: "", url: "bbb", commentLink: "", thumbnail: "", upvoteCount: 9, commentCount: 0, fetchedAt: "")
		let postC  = Post(id: "", author: "c1", created: 0, title: "Post C", version: 0, domain: "", url: "ccc", commentLink: "", thumbnail: "", upvoteCount: -1, commentCount: 0, fetchedAt: "")
		let postB2 = Post(id: "", author: "b2", created: 0, title: "Post B", version: 0, domain: "", url: "bbb", commentLink: "", thumbnail: "", upvoteCount: 3, commentCount: 0, fetchedAt: "")

		// Create the post downloader object
		let postDownloader = PostDownloader()
		postDownloader.posts = [postA, postB, postC, postB2]
		
		// Calculate expected result
		postDownloader.sortPosts()
		postDownloader.removeDuplicates()
		
		// Check for expected result
		XCTAssertTrue(postDownloader.posts.count == 3)
		XCTAssertTrue(postDownloader.posts[0] == postA)
		//make sure the higher upvoted post B is chosen (!assuming presorted!)
		XCTAssertTrue(postDownloader.posts[1] == postB && postDownloader.posts[1].author == "b1")
		XCTAssertTrue(postDownloader.posts[2] == postC)
	}
    
    func testJSONPostModelDecode() {
        
        let jsonMockStringObject = JSONMock()
        
        print(jsonMockStringObject.jsonString)
        
        guard let data = Data(base64Encoded: jsonMockStringObject.jsonString) else {
            XCTFail()
            return
        }
        
        var posts = [Post]()
        var downloaded = false
        
        do {
            let downloadedPosts = try JSONDecoder().decode([Post].self, from: data)
            posts = downloadedPosts
            downloaded = true
            
        } catch let jsonError {
            print("Error serializing JSON from remote server \(jsonError)")
        }
        
        while downloaded == false {
            
        }
        
        XCTAssertNotNil(posts[0])
        
        XCTAssertEqual(posts[0].title, "Trump Puts Iran Nuclear Deal In Limbo, Calling Agreement 'Unacceptable'")
        XCTAssertEqual(posts[0].upvoteCount, 14)
        XCTAssertEqual(posts[0].id, "59e0fce0cb12924511ecdb77")
        
        XCTAssertNotEqual(posts[0].title, "")
    }
    
    func testResponseFromServer() {
        
        let postDownloader = PostDownloader()
        
        postDownloader.downloadPosts()
        
        while postDownloader.downloaded == false {
            
        }
        
        XCTAssertNotNil(postDownloader)
        XCTAssertNotNil(postDownloader.posts[0].title)
        
        
    }
    
}
