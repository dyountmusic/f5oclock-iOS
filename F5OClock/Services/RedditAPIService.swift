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
        let url = RedditURL.baseUrl.rawValue
        let path = "/api/v1/me"
        
        request(url: url + path, parameters: nil, headers: nil, body: nil, method: .GET) { (response, error) in
            if error != nil {
                print("Get User Info Failed with error: \(String(describing: error?.localizedDescription))")
                completionHandler(nil, error)
            } else {
                do {
                    guard let response = response else { return }
                    let redditUser = try JSONDecoder().decode(RedditUser.self, from: response.data)
                    completionHandler(redditUser, nil)
                } catch let jsonError {
                    print("Error serializing JSON from remote server \(jsonError.localizedDescription)")
                    completionHandler(nil, jsonError)
                }
            }
        }
    }
    
    // MARK: Voting Functions
    
    func upvotePost(id: String, type: String) {
        print("upvote...")
        let parameters = [
            "dir" : "1",
            "id" : "\(type)_\(id)",
            "rank" : "2"
            ]
        vote(id: id, type: type, parameters: parameters)
    }
    
    func downVotePost(id: String, type: String) {
        print("downvote...")
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
        request(url: RedditURL.baseUrl.rawValue + "/api/vote", parameters: parameters, headers: nil, body: nil, method: .POST) { (response, error) in
            if error != nil {
                print("Error Posting Vote to Reddit: \(String(describing: error?.localizedDescription)).")
            }
        }
    }
    
    // Private Methods
    
    private func request(url: String, parameters: [String : String]?, headers: [String : String]?, body: Data?, method: OAuthSwiftHTTPRequest.Method, completionHandler: @escaping (OAuthSwiftResponse?, Error?) -> ()) {
        guard let client = authService.getAuthorizedClient() else { print("Authorized client not found"); return }
        
        let _ = client.request(url, method: method, parameters: parameters ?? ["":""], headers: headers, body: body, checkTokenExpiration: true, success: { (response) in
            // Success
            completionHandler(response, nil)
        }) { (error) in
            self.handleFailure(error: error, completionHandler: { (error) in
                if error != nil {
                    print("RedditAPI request failed, after attempting to handle: \(String(describing: error?.localizedDescription))")
                }
            })
        }
    }
    
    private func handleFailure(error: Error?, completionHandler: @escaping (Error?) -> Void) {
        guard let error = error?.localizedDescription else { return }
        if error.description == "The operation couldn’t be completed. (OAuthSwiftError error -2.)" {
            self.authService.renewAccessToken { (error) in
                if error == nil {
                    // Success
                    completionHandler(nil)
                } else {
                    // Failure
                    print("Failed to renew access token with error: \(String(describing: error?.localizedDescription))")
                    completionHandler(error)
                }
            }
        }
    }
    
    // MARK: Initializers
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
}
