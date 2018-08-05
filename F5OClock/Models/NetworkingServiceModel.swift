//
//  NetworkingServiceModel.swift
//  F5OClock
//
//  Created by Daniel Yount on 8/4/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import Foundation
import OAuthSwift

class NetworkingSerivceModel {
    
    var oauthAuthorizer: OAuthSwift? {
        didSet {
            print("Set the oauth auth model obj!")
        }
    }
    
    var redditUser: RedditUser?
    
}
