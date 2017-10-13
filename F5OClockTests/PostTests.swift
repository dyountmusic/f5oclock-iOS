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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFindHighestUpvotedPost() {
        // Mocked Post objects
        let highestPost = Post(id: "", author: "", created: 0, title: "Highest Post", version: 0, domain: "", url: "", commentLink: "", thumbnail: "", upvoteCount: 2, commentCount: 0, fetchedAt: "")
        let lowestPost =  Post(id: "", author: "", created: 0, title: "Lowest Post", version: 0, domain: "", url: "", commentLink: "", thumbnail: "", upvoteCount: 1, commentCount: 0, fetchedAt: "")
        let negativePost = Post(id: "", author: "", created: 0, title: "Negative Post", version: 0, domain: "", url: "", commentLink: "", thumbnail: "", upvoteCount: -1, commentCount: 0, fetchedAt: "")
        
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
    
    func testJSONPostModelDecode() {
        
        let jsonString = """
        W3siX2lkIjoiNTllMGZjZTBjYjEyOTI0NTExZWNkYjc3IiwiYXV0aG9yIjoiR3JvdW5kUG9ydGVyIiwiY3JlYXRlZF91dGMiOjE1MDc5MTYzOTcsInRpdGxlIjoiVHJ1bXAgUHV0cyBJcmFuIE51Y2xlYXIgRGVhbCBJbiBMaW1ibywgQ2FsbGluZyBBZ3JlZW1lbnQgJ1VuYWNjZXB0YWJsZSciLCJfX3YiOjAsImRvbWFpbiI6Im5wci5vcmciLCJ1cmwiOiJodHRwOi8vd3d3Lm5wci5vcmcvMjAxNy8xMC8xMy81NTY2NjQzMzgvdHJ1bXAtdG8tcHV0LWlyYW4tbnVjbGVhci1kZWFsLWluLWxpbWJvLWJ5LXJlZnVzaW5nLXRvLWNlcnRpZnkiLCJjb21tZW50TGluayI6Ii9yL3BvbGl0aWNzL2NvbW1lbnRzLzc2NmV2Zi90cnVtcF9wdXRzX2lyYW5fbnVjbGVhcl9kZWFsX2luX2xpbWJvX2NhbGxpbmcvIiwidGh1bWJuYWlsIjoiaHR0cHM6Ly9hLnRodW1icy5yZWRkaXRtZWRpYS5jb20vLTZvVWJDeUdUd25wZDcwZ3hZUlFlckc5enZzQUEwTG5KM1NQOThkSG40MC5qcGciLCJ1cHZvdGVDb3VudCI6MTQsImNvbW1lbnRDb3VudCI6MSwiZmV0Y2hlZEF0IjoiMjAxNy0xMC0xM1QxNzo1ODoyNy4wNThaIn0seyJfaWQiOiI1OWUwZmQ1NWNiMTI5MjQ1MTFlY2RiNzgiLCJhdXRob3IiOiJZaWJibGV0cyIsImNyZWF0ZWRfdXRjIjoxNTA3OTE2NTA2LCJ0aXRsZSI6IlRydW1wIFNheXMgSGUgTWV0IFdpdGggVGhlIFByZXNpZGVudCBPZiBUaGUgVmlyZ2luIElzbGFuZHMsIFdoaWNoIElzLi4uIFRydW1wIiwiX192IjowLCJkb21haW4iOiJodWZmaW5ndG9ucG9zdC5jb20iLCJ1cmwiOiJodHRwczovL3d3dy5odWZmaW5ndG9ucG9zdC5jb20vZW50cnkvdHJ1bXAtcHJlc2lkZW50LXZpcmdpbi1pc2xhbmRzX3VzXzU5ZTBkY2VhZTRiMDNhN2JlNTgwMzMxMz9uY2lkPWluYmxua3VzaHBtZzAwMDAwMDA5IiwiY29tbWVudExpbmsiOiIvci9wb2xpdGljcy9jb21tZW50cy83NjZmYmIvdHJ1bXBfc2F5c19oZV9tZXRfd2l0aF90aGVfcHJlc2lkZW50X29mX3RoZS8iLCJ0aHVtYm5haWwiOiJodHRwczovL2IudGh1bWJzLnJlZGRpdG1lZGlhLmNvbS9sbGlxQ1lqUG5laWRZZE9JTmNLQTN3OUdZVXQyVEJENWl5MEk4bDVJeUFVLmpwZyIsInVwdm90ZUNvdW50IjoyNiwiY29tbWVudENvdW50Ijo1LCJmZXRjaGVkQXQiOiIyMDE3LTEwLTEzVDE4OjA1OjE3LjkzMloifSx7Il9pZCI6IjU5ZTBmZGNiY2IxMjkyNDUxMWVjZGI3OSIsImF1dGhvciI6Im9sZGJyb2tlbnJlY29yZCIsImNyZWF0ZWRfdXRjIjoxNTA3OTE2NjM5LCJ0aXRsZSI6IldoYXQgVHJ1bXAncyBtb3ZlIG9uIElyYW4gbWVhbnMgZm9yIHRoZSBVUyBhbmQgdGhlIHdvcmxkIiwiX192IjowLCJkb21haW4iOiJjbm4uY29tIiwidXJsIjoiaHR0cDovL3d3dy5jbm4uY29tLzIwMTcvMTAvMTMvcG9saXRpY3MvdHJ1bXAtaXJhbi1hbmFseXNpcy9pbmRleC5odG1sIiwiY29tbWVudExpbmsiOiIvci9wb2xpdGljcy9jb21tZW50cy83NjZmdDYvd2hhdF90cnVtcHNfbW92ZV9vbl9pcmFuX21lYW5zX2Zvcl90aGVfdXNfYW5kX3RoZS8iLCJ0aHVtYm5haWwiOiJodHRwczovL2IudGh1bWJzLnJlZGRpdG1lZGlhLmNvbS9vRTdXU0dsQUVPSlFjY3VCY2RwWHZVQkFGbU5xOEFHZ2pMUU5aYnNfeFV3LmpwZyIsInVwdm90ZUNvdW50IjoxMCwiY29tbWVudENvdW50IjoxLCJmZXRjaGVkQXQiOiIyMDE3LTEwLTEzVDE3OjU4OjI3LjA1OFoifSx7Il9pZCI6IjU5ZTBmZTQ3Y2IxMjkyNDUxMWVjZGI3YSIsImF1dGhvciI6ImJpbGx0aG9tc29uIiwiY3JlYXRlZF91dGMiOjE1MDc5MTY2NzAsInRpdGxlIjoiRG9uYWxkIFRydW1wIGlzIGEgUHVlcnRvIFJpY28gZGlzYXN0ZXIgZGVuaWVyLiIsIl9fdiI6MCwiZG9tYWluIjoibmV3cmVwdWJsaWMuY29tIiwidXJsIjoiaHR0cHM6Ly9uZXdyZXB1YmxpYy5jb20vbWludXRlcy8xNDUzMDAvZG9uYWxkLXRydW1wLXB1ZXJ0by1yaWNvLWRpc2FzdGVyLWRlbmllciIsImNvbW1lbnRMaW5rIjoiL3IvcG9saXRpY3MvY29tbWVudHMvNzY2ZnlsL2RvbmFsZF90cnVtcF9pc19hX3B1ZXJ0b19yaWNvX2Rpc2FzdGVyX2Rlbmllci8iLCJ0aHVtYm5haWwiOiJodHRwczovL2EudGh1bWJzLnJlZGRpdG1lZGlhLmNvbS9FWWcyRmNaVzZMbU9FU3N5LW5LWnNmeFJxNkNDR3l6ZExaVXFtOGZGYjg0LmpwZyIsInVwdm90ZUNvdW50IjoxMzgsImNvbW1lbnRDb3VudCI6MTMsImZldGNoZWRBdCI6IjIwMTctMTAtMTNUMTg6MDU6MTcuOTI5WiJ9LHsiX2lkIjoiNTllMGZmMzhjYjEyOTI0NTExZWNkYjdjIiwiYXV0aG9yIjoidHJlZXJhdCIsImNyZWF0ZWRfdXRjIjoxNTA3OTE2OTYwLCJ0aXRsZSI6IkNvbm5lY3RpY3V0IFdpbGwgU3VlIFRydW1wIEFkbWluaXN0cmF0aW9uIEZvciBFbmRpbmcgQWZmb3JkYWJsZSBDYXJlIEFjdCBTdWJzaWRpZXMiLCJfX3YiOjAsImRvbWFpbiI6ImNvdXJhbnQuY29tIiwidXJsIjoiaHR0cDovL3d3dy5jb3VyYW50LmNvbS9wb2xpdGljcy9oYy1wb2wtamVwc2VuLWxhd3N1aXQtdHJ1bXAtYWZmb3JkYWJsZS1jYXJlLWFjdC0yMDE3MTAxMy1zdG9yeS5odG1sIiwiY29tbWVudExpbmsiOiIvci9wb2xpdGljcy9jb21tZW50cy83NjZoN2wvY29ubmVjdGljdXRfd2lsbF9zdWVfdHJ1bXBfYWRtaW5pc3RyYXRpb25fZm9yLyIsInRodW1ibmFpbCI6Imh0dHBzOi8vYi50aHVtYnMucmVkZGl0bWVkaWEuY29tL3VVdVBGMEV4ZWZxaUVCbkd0VE5LWEt1SGZCWlZxTHZvWHFONkdGekg5VlUuanBnIiwidXB2b3RlQ291bnQiOjQ5LCJjb21tZW50Q291bnQiOjMsImZldGNoZWRBdCI6IjIwMTctMTAtMTNUMTg6MDU6MTcuOTMwWiJ9LHsiX2lkIjoiNTllMGZmMzhjYjEyOTI0NTExZWNkYjdiIiwiYXV0aG9yIjoiMTIzQWR6MzIxIiwiY3JlYXRlZF91dGMiOjE1MDc5MTY5OTksInRpdGxlIjoiRVUgY29uZGVtbnMgRG9uYWxkIFRydW1wJ3MgZGVjaXNpb24gdG8gZGVjZXJ0aWZ5IGFncmVlbWVudCIsIl9fdiI6MCwiZG9tYWluIjoiaW5kZXBlbmRlbnQuY28udWsiLCJ1cmwiOiJodHRwOi8vd3d3LmluZGVwZW5kZW50LmNvLnVrL25ld3Mvd29ybGQvcG9saXRpY3MvaXJhbi1udWNsZWFyLWRlYWwtdHJ1bXAtZXUtZmVkZXJpY2EtbW9naGVyaW5pLW5ldGFueWFodS1pc3JhZWwtYTc5OTk1NTYuaHRtbCIsImNvbW1lbnRMaW5rIjoiL3IvcG9saXRpY3MvY29tbWVudHMvNzY2aGRwL2V1X2NvbmRlbW5zX2RvbmFsZF90cnVtcHNfZGVjaXNpb25fdG9fZGVjZXJ0aWZ5LyIsInRodW1ibmFpbCI6Imh0dHBzOi8vYi50aHVtYnMucmVkZGl0bWVkaWEuY29tL09PUkl2cTF1RG11OVlDTGlRSXdycHFMWUQzR1dtWmVFbUFFM0dHS2ozek0uanBnIiwidXB2b3RlQ291bnQiOjU5LCJjb21tZW50Q291bnQiOjcsImZldGNoZWRBdCI6IjIwMTctMTAtMTNUMTg6MDU6MTcuOTMwWiJ9LHsiX2lkIjoiNTllMGZmMzhjYjEyOTI0NTExZWNkYjdkIiwiYXV0aG9yIjoibG9raTg0ODEiLCJjcmVhdGVkX3V0YyI6MTUwNzkxNzAwMywidGl0bGUiOiJIYXJ2ZXkgV2VpbnN0ZWluIFNjYW5kYWwgU3B1cnMgTGF3bWFrZXJzIFRvIEdvIEFmdGVyIE5vbmRpc2Nsb3N1cmUgQWdyZWVtZW50cyIsIl9fdiI6MCwiZG9tYWluIjoiYnV6emZlZWQuY29tIiwidXJsIjoiaHR0cHM6Ly93d3cuYnV6emZlZWQuY29tL2NsYXVkaWFrb2VybmVyL25ldy15b3JrLWxhd21ha2Vycy1jb25maWRlbnRpYWxpdHktYWdyZWVtZW50cyIsImNvbW1lbnRMaW5rIjoiL3IvcG9saXRpY3MvY29tbWVudHMvNzY2aGUxL2hhcnZleV93ZWluc3RlaW5fc2NhbmRhbF9zcHVyc19sYXdtYWtlcnNfdG9fZ28vIiwidGh1bWJuYWlsIjoiaHR0cHM6Ly9hLnRodW1icy5yZWRkaXRtZWRpYS5jb20vNmU5allTYnl4dXlQNlZtZGVvQnlHLUhKc0NRRDB6VUR6Nmt0b1hIbnBDMC5qcGciLCJ1cHZvdGVDb3VudCI6MTYsImNvbW1lbnRDb3VudCI6NywiZmV0Y2hlZEF0IjoiMjAxNy0xMC0xM1QxODowNToxNy45MzJaIn0seyJfaWQiOiI1OWUwZmZiZWNiMTI5MjQ1MTFlY2RiN2UiLCJhdXRob3IiOiJ1bmhvbHlwcmF3biIsImNyZWF0ZWRfdXRjIjoxNTA3OTE3MTAxLCJ0aXRsZSI6IldIIHNlZWtzIHRvIGN1dCBiYWNrIHNwZW5kaW5nIGFzIGRpc2FzdGVyIHJlbGllZiBzcGVuZGluZyBtb3VudHMiLCJfX3YiOjAsImRvbWFpbiI6InRoZWhpbGwuY29tIiwidXJsIjoiaHR0cDovL3RoZWhpbGwuY29tL3BvbGljeS9maW5hbmNlLzM1NTM0MC13aC1zZWVrcy10by1jdXQtYmFjay1zcGVuZGluZy1hcy1kaXNhc3Rlci1yZWxpZWYtc3BlbmRpbmctbW91bnRzIiwiY29tbWVudExpbmsiOiIvci9wb2xpdGljcy9jb21tZW50cy83NjZodWQvd2hfc2Vla3NfdG9fY3V0X2JhY2tfc3BlbmRpbmdfYXNfZGlzYXN0ZXJfcmVsaWVmLyIsInRodW1ibmFpbCI6Imh0dHBzOi8vYi50aHVtYnMucmVkZGl0bWVkaWEuY29tL1BBYklXWThueUJjeTd5OUExTi1mOWtHdlZnWkMxQ1FBZEFQeGF6MUVHWGMuanBnIiwidXB2b3RlQ291bnQiOjEwLCJjb21tZW50Q291bnQiOjEsImZldGNoZWRBdCI6IjIwMTctMTAtMTNUMTg6MDU6MTcuOTM0WiJ9XQ==
        """
        
        guard let data = Data(base64Encoded: jsonString) else {
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
    
}
