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
    
    var oauthSwift: OAuthSwift
    var redditUser: RedditUser
    
    init (oauth: OAuthSwift, user: RedditUser) {
        self.oauthSwift = oauth
        self.redditUser = user
    }
    
}
