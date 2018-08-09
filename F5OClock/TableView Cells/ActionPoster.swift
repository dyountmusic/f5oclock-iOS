//
//  ActionPoster.swift
//  F5OClock
//
//  Created by Tim Miller on 8/9/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import Foundation

protocol ActionPoster {
    func upvote(_ id: String, type: String)
    func downvote(_ id: String, type: String)
}
