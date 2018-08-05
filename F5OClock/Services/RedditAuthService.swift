//
//  RedditOAuthService.swift
//  F5OClock
//
//  Created by Daniel Yount on 8/3/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import Foundation
import OAuthSwift
import KeychainSwift

enum RedditAuthorizationStrings: String {
    case baseURL = "https://oauth.reddit.com"
    case authURL = "https://www.reddit.com/api/v1/authorize.compact?"
    case accessTokenURL = "https://www.reddit.com/api/v1/access_token"
    case clientID = "1dz4paXlzSx97w"
}

class RedditAuthService : AuthService {
    
    private let appContext: AppContext
    private var oauthSwift: OAuth2Swift?
    
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
            self.storeTokenToKeychain(cred: credential)
            self.appContext.identity = Identity(credential: credential, user: RedditUser())
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
                    self.appContext.identity = Identity(credential: identity!.credential, user: redditUser)
                    success()
                } catch let jsonError {
                    print("Error serializing JSON from remote server \(jsonError.localizedDescription)")
                }
            }, failure: { (error) in
                print("Error retriving identity from reddit: \(error)")
                
            })
        }
    }
    
    private func checkKeychainForToken() {
        let keychain = KeychainSwift()
        guard let accessToken = keychain.get("access-token") else { return }
        guard let accessTokenSecret = keychain.get("access-token-secret") else { return }
    }
    
    private func storeTokenToKeychain(cred: OAuthSwiftCredential) {
        let keychain = KeychainSwift()
        keychain.synchronizable = true
        print("This is the client token: \(cred.consumerKey)")
        print("This is the client token secret: \(cred.consumerSecret)")
        print("Setting access token: \(cred.oauthToken)")
        print("Setting access token secret: \(cred.oauthTokenSecret)")
        keychain.set(cred.oauthToken, forKey: "access-token")
        keychain.set(cred.oauthTokenSecret, forKey: "access-token-secret")
    }
    
    func getAuthorizedClient() -> OAuthSwiftClient? {
        return self.oauthSwift?.client
    }
    
    init(appContext: AppContext) {
        self.appContext = appContext
    }
    
}
