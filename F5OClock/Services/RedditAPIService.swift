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
    
    // MARK: User Information Requests
    
    func getUserInfo(_ vc: UIViewController, completionHandler: @escaping (RedditUser?, Error?) -> Void) {
        let url = RedditURL.baseURL.rawValue
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
                self.authService.renewAccessToken(completionHandler: { (error) in
                    if error == nil {
                        // Try request again
                        self.getUserInfo(vc, completionHandler: { (user, error) in
                            completionHandler(user, error)
                        })
                    } else {
                        print("Failed to renew access token.")
                    }
                })
                
                
            }
            completionHandler(nil, error)
        })
        
    }
    
    // MARK: Voting Functions
    
    func upvotePost(id: String, type: String) {
        let parameters = [
            "dir" : "1",
            "id" : "\(type)_\(id)",
            "rank" : "2"
            ]
        vote(id: id, type: type, parameters: parameters)
    }
    
    func downVotePost(id: String, type: String) {
        let parameters = [
            "dir" : "-1",
            "id" : "\(type)_\(id)",
            "rank" : "2"
        ]
        vote(id: id, type: type, parameters: parameters)
    }
    
    func resetVote(id: String, type: String) {
        let parameters = [
            "dir" : "0",
            "id" : "\(type)_\(id)",
            "rank" : "2"
        ]
        vote(id: id, type: type, parameters: parameters)
    }
    
    // Abstracted vote method
    private func vote(id: String, type: String, parameters: [String : String]) {
        let client = authService.getAuthorizedClient()
        
        let _ = client?.post(RedditURL.baseURL.rawValue + "/api/vote", parameters: parameters, headers: nil, body: nil, success: { (respoinse) in
            // Success
        }, failure: { (error) in
            // Failure
            print(error.localizedDescription)
        })
    }
    
    // MARK: Initializers
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
}
