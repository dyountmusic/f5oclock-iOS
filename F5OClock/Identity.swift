//
//  IdentityContext.swift
//  F5OClock
//
//  Created by Tim Miller on 8/4/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import Foundation

class Identity {
    
    let accessToken: String
    let refreshToken: String
    let name: String
    
    init (accessToken: String, refreshToken: String, name: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.name = name
    }
    
}
