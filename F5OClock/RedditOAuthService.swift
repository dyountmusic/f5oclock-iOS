//
//  RedditOAuthService.swift
//  F5OClock
//
//  Created by Daniel Yount on 8/3/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import Foundation
import OAuthSwift

enum AuthorizationStrings: String {
    case baseURL = "https://oauth.reddit.com"
    case authURL = "https://www.reddit.com/api/v1/authorize.compact?"
    case accessTokenURL = "https://www.reddit.com/api/v1/access_token"
    case clientID = "1dz4paXlzSx97w"
}

extension SettingsViewController {
    
    func handleAuth() {
        
        let oauthswift = OAuth2Swift(consumerKey: AuthorizationStrings.clientID.rawValue,
                    consumerSecret: "",
                    authorizeUrl: AuthorizationStrings.authURL.rawValue,
                    accessTokenUrl: AuthorizationStrings.accessTokenURL.rawValue,
                    responseType: "token"
        )
        
        oauthswift.accessTokenBasicAuthentification = true
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
        
        oauthAuthorizer = oauthswift
        
        let state = generateState(withLength: 20)
        let parameters = [
            "client_id" : AuthorizationStrings.clientID.rawValue,
            "response_type" : "code",
            "state" : state,
            "redirect_uri" : "f5oclock://callback",
            "duration" : "permanent",
            "scope" : "vote identity mysubreddits"
        ]
        
        let _ = oauthswift.authorize(withCallbackURL: "f5oclock://callback", scope: "vote identity mysubreddits", state: state, parameters: parameters, headers: nil, success: { (credential, response, parameters) in
            // Success
        }) { (error) in
            print("Authentication Error: \(error.description)")
        }
    }
    
    
    
}
