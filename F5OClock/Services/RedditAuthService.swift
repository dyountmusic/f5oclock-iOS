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
            self.storeTokensToDisk(cred: credential)
            self.initializeIdentity(credential: credential, success)
        }) { (error) in
            print("Authentication Error: \(error.description)")
        }
    }
    
    func initializeIdentity(credential: OAuthSwiftCredential, _ success: @escaping() -> ()) {
        guard let oauthSwift = self.oauthSwift else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            oauthSwift.client.request(RedditAuthorizationStrings.baseURL.rawValue + "/api/v1/me", method: .GET, success: { (response) in
                do {
                    let redditUser = try JSONDecoder().decode(RedditUser.self, from: response.data)
                    self.appContext.identity = Identity(credential: credential, user: redditUser)
                    self.storeUserToDisk(name: redditUser.name)
                    success()
                } catch let jsonError {
                    print("Error serializing JSON from remote server \(jsonError.localizedDescription)")
                }
            }, failure: { (error) in
                print("Error retriving identity from reddit: \(error)")
                
            })
        }
    }
    
    private func storeTokensToDisk(cred: OAuthSwiftCredential) {
        let userDefaults = UserDefaults()
        userDefaults.set(cred.oauthToken, forKey: "oauth-token")
        userDefaults.set(cred.oauthTokenSecret, forKey: "oauth-token-secret")
        userDefaults.set(cred.oauthRefreshToken, forKey: "oauth-refresh-token")
    }
    
    private func storeUserToDisk(name: String) {
        let userDefaults = UserDefaults()
        userDefaults.set(name, forKey: "currentAuthenticatedUser")
    }
    
    internal func restoreAuthorizedUser() {
        let restoreableOauthSwift = OAuth2Swift(consumerKey: RedditAuthorizationStrings.clientID.rawValue,
                                    consumerSecret: "",
                                    authorizeUrl: RedditAuthorizationStrings.authURL.rawValue,
                                    accessTokenUrl: RedditAuthorizationStrings.accessTokenURL.rawValue,
                                    responseType: "token"
        )
        
        let userDefaults = UserDefaults()
        guard let token = userDefaults.string(forKey: "oauth-token") else { print("Oauth Token Not found"); return }
        guard let tokenSecret = userDefaults.string(forKey: "oauth-token-secret") else { print("Oauth Token Secret Not found"); return }
        guard let refreshToken = userDefaults.string(forKey: "oauth-refresh-token") else { print("Refresh Token Not found"); return }
        
        restoreableOauthSwift.client.credential.oauthToken = token
        restoreableOauthSwift.client.credential.oauthRefreshToken = refreshToken
        restoreableOauthSwift.client.credential.oauthTokenSecret = tokenSecret
        
        guard let user = userDefaults.string(forKey: "currentAuthenticatedUser") else { print("Couldn't get current authenticated user"); return }

        self.appContext.identity = Identity(credential: restoreableOauthSwift.client.credential, user: RedditUser(name: user))
        self.oauthSwift = restoreableOauthSwift
    }
    
    func getAuthorizedClient(_ vc: UIViewController) -> OAuthSwiftClient? {
        guard let client = self.oauthSwift?.client else {
            let loginAlert = UIAlertController.init(title: "Login to Continue", message: "You must be logged in to perform that action.", preferredStyle: .alert)
            loginAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                
            }))
            vc.present(loginAlert, animated: true, completion: nil)
            
            return nil
        }
        
        return client
    }
    
    func renewAccessToken() {
        guard let oauth = oauthSwift else { return }
        oauth.accessTokenBasicAuthentification = true
        guard let refreshToken = UserDefaults().string(forKey: "oauth-refresh-token") else { return }
        
        oauth.renewAccessToken(withRefreshToken: refreshToken, success: { (credential, response, parameters) in
            // Success
            
        }) { (error) in
            // Failure
            print(error.localizedDescription)
        }
        
        
    }
    
    init(appContext: AppContext) {
        self.appContext = appContext
    }
    
}
