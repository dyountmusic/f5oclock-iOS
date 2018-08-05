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
    
    func getUserInfo(completionHandler: @escaping (RedditUser?, Error?) -> Void) {
        let url = RedditAuthorizationStrings.baseURL.rawValue
        let path = "/api/v1/me"
        let result = networkServiceModel?.oauthAuthorizer?.client.get(url + path, success: { (response) in
            // Success
            print("Got response!")
            print(response.dataString())
            do {
                let redditUser = try JSONDecoder().decode(RedditUser.self, from: response.data)
                completionHandler(redditUser, nil)
            } catch let jsonError {
                print("Error serializing JSON from remote server \(jsonError.localizedDescription)")
                completionHandler(nil, jsonError)
            }
        }, failure: { (error) in
            completionHandler(nil, error)
        })
        
    }
    
    func upvotePost() {
        
    }
    
    func downVotePost() {
        
    }
    
    
}