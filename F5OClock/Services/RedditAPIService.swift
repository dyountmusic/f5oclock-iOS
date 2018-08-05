//
//  RedditAPIService.swift
//  F5OClock
//
//  Created by Daniel Yount on 8/4/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import Foundation
import OAuthSwift

struct RedditRequestModel {
    var url: String
    var method: OAuthSwiftHTTPRequest.Method
    var path: String
}


class RedditAPIService {
    
    var networkServiceModel: NetworkingSerivceModel?
    
    func getUserInfo() {
        
    }
    
    func upvotePost() {
        
    }
    
    func downVotePost() {
        
    }
    
    
}
