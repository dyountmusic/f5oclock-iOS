//
//  RedditDownloadService.swift
//  F5OClock
//
//  Created by Daniel Yount on 8/19/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import Foundation

struct RedditDownloaderService: RedditDownloaderServiceProtocol {
    
    func fetchDownloader(downloadType: RedditDownloader) -> RedditDownloaderProtocol {
        switch downloadType {
        case .Post:
            return RedditPostDownloadService()
        case .UserIdentity:
            return RedditIdentityDownloadService()
        }
    }
    
}
