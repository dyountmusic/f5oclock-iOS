//
//  RedditAPIService.swift
//  F5OClock
//
//  Created by Daniel Yount on 8/4/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import Foundation
import OAuthSwift

class RedditAPIService {
    
    var networkServiceModel: NetworkingSerivceModel?
    
    func getUserInfo() {
        let url = RedditAuthorizationStrings.baseURL.rawValue
        let path = "/api/v1/me"
        networkServiceModel?.oauthAuthorizer?.client.get(url + path, success: { (response) in
            // Success
            print("Got response!")
            print(response.dataString())
            do {
                let redditUser = try JSONDecoder().decode(RedditUser.self, from: response.data)
                
            } catch let jsonError {
                print("Error serializing JSON from remote server \(jsonError.localizedDescription)")
            }
        }, failure: { (error) in
            // Failure
        })
        
    }
    
    func upvotePost() {
        
    }
    
    func downVotePost() {
        
    }
    
    
}
