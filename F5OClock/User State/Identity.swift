//
//  IdentityContext.swift
//  F5OClock
//
//  Created by Tim Miller on 8/4/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import Foundation
import OAuthSwift

class Identity {
    
    let credential: OAuthSwiftCredential
    let redditUser: RedditUser
    
    init (credential: OAuthSwiftCredential, user: RedditUser) {
        self.credential = credential
        self.redditUser = user
    }
    
}
