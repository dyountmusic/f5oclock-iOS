//
//  RedditOAuthService.swift
//  F5OClock
//
//  Created by Daniel Yount on 8/3/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import Foundation
import OAuthSwift

enum RedditAuthorizationStrings: String {
    case baseURL = "https://oauth.reddit.com"
    case authURL = "https://www.reddit.com/api/v1/authorize.compact?"
    case accessTokenURL = "https://www.reddit.com/api/v1/access_token"
    case clientID = "1dz4paXlzSx97w"
}

extension SettingsViewController {
    
    func handleAuth() {
        let oauthswift = OAuth2Swift(consumerKey: RedditAuthorizationStrings.clientID.rawValue,
                    consumerSecret: "",
                    authorizeUrl: RedditAuthorizationStrings.authURL.rawValue,
                    accessTokenUrl: RedditAuthorizationStrings.accessTokenURL.rawValue,
                    responseType: "token"
        )
        
        oauthswift.accessTokenBasicAuthentification = true
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
        
        apiService.networkServiceModel.oauthAuthorizer = oauthswift
        
        let state = generateState(withLength: 20)
        let parameters = [
            "client_id" : RedditAuthorizationStrings.clientID.rawValue,
            "response_type" : "code",
            "state" : state,
            "redirect_uri" : "f5oclock://callback",
            "duration" : "permanent",
            "scope" : "vote identity mysubreddits"
        ]
        
        let _ = oauthswift.authorize(withCallbackURL: "f5oclock://callback", scope: "vote identity mysubreddits", state: state, parameters: parameters, headers: nil, success: { (credential, response, parameters) in
            // Success
            self.retrieveIdentity()
        }) { (error) in
            print("Authentication Error: \(error.description)")
        }
    }
    
    func retrieveIdentity() {
        guard let authorizer = apiService.networkServiceModel.oauthAuthorizer else { return }
        authorizer.client.request(RedditAuthorizationStrings.baseURL.rawValue + "/api/v1/me", method: .GET, success: { (response) in
            do {
                let redditUser = try JSONDecoder().decode(RedditUser.self, from: response.data)
                self.redditUser = redditUser
            } catch let jsonError {
                print("Error serializing JSON from remote server \(jsonError.localizedDescription)")
            }
        }, failure: { (error) in
            print("Error retriving identity from reddit: \(error)")
            
        })
    }
    
    
    
}
