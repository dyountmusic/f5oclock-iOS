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
    let name: String
    
    init (credential: OAuthSwiftCredential, name: String) {
        self.credential = credential
        self.name = name
    }
    
}
