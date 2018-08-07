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
    
    private let authService: AuthService
    
    func getUserInfo(_ vc: UIViewController, completionHandler: @escaping (RedditUser?, Error?) -> Void) {
        let url = RedditAuthorizationStrings.baseURL.rawValue
        let path = "/api/v1/me"
        
        guard let client = self.authService.getAuthorizedClient(vc) else { return }
        
        _ = client.get(url + path, success: { (response) in
            // Success
            do {
                let redditUser = try JSONDecoder().decode(RedditUser.self, from: response.data)
                completionHandler(redditUser, nil)
            } catch let jsonError {
                print("Error serializing JSON from remote server \(jsonError.localizedDescription)")
                completionHandler(nil, jsonError)
            }
        }, failure: { (error) in
            if error.localizedDescription.description == "The operation couldn’t be completed. (OAuthSwiftError error -2.)" {
                self.authService.renewAccessToken()
                // Try request again
                self.getUserInfo(vc, completionHandler: { (user, error) in
                    completionHandler(user, error)
                })
            }
            completionHandler(nil, error)
        })
        
    }
    
    
    
    func upvotePost() {
        
    }
    
    func downVotePost() {
        
    }
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
}
