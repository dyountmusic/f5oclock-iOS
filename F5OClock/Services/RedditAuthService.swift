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

class RedditAuthService : AuthService {
    
    let appContext: AppContext
    var oauthSwift: OAuth2Swift?
    
    func authorizeUser(initiatingViewController: UIViewController, _ success: @escaping () -> ()) {
        let oauthswift = OAuth2Swift(consumerKey: RedditAuthorizationStrings.clientID.rawValue,
                    consumerSecret: "",
                    authorizeUrl: RedditAuthorizationStrings.authURL.rawValue,
                    accessTokenUrl: RedditAuthorizationStrings.accessTokenURL.rawValue,
                    responseType: "token"
        )
        
        oauthswift.accessTokenBasicAuthentification = true
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: initiatingViewController, oauthSwift: oauthswift)
        
        self.oauthSwift = oauthswift
        
        let state = generateState(withLength: 20)
        let parameters = [
            "client_id" : RedditAuthorizationStrings.clientID.rawValue,
            "response_type" : "code",
            "state" : state,
            "redirect_uri" : "f5oclock://oauthcallback",
            "duration" : "permanent",
            "scope" : "vote identity mysubreddits"
        ]
        
        let _ = oauthswift.authorize(withCallbackURL: "f5oclock://oauthcallback", scope: "vote identity mysubreddits", state: state, parameters: parameters, headers: nil, success: { (credential, response, parameters) in
            // Success
            self.appContext.identity = Identity(credential: credential, name: "")
            self.initializeIdentity(success)
        }) { (error) in
            print("Authentication Error: \(error.description)")
        }
    }
    
    func initializeIdentity(_ success: @escaping() -> ()) {
        guard let oauthSwift = self.oauthSwift else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            oauthSwift.client.request(RedditAuthorizationStrings.baseURL.rawValue + "/api/v1/me", method: .GET, success: { (response) in
                do {
                    let redditUser = try JSONDecoder().decode(RedditUser.self, from: response.data)
                    let identity = self.appContext.identity
                    self.appContext.identity = Identity(credential: identity!.credential, name: redditUser.name)
                    success()
                } catch let jsonError {
                    print("Error serializing JSON from remote server \(jsonError.localizedDescription)")
                }
            }, failure: { (error) in
                print("Error retriving identity from reddit: \(error)")
                
            })
        }
    }
    
    func getAuthorizedClient() -> OAuthSwiftClient? {
        return self.oauthSwift?.client
    }
    
    init(appContext: AppContext) {
        self.appContext = appContext
    }
    
}
