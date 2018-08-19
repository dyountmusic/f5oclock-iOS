//
//  DownloaderProtocols.swift
//  
//
//  Created by Daniel Yount on 8/19/18.
//

import Foundation

protocol RedditDownloaderServiceProtocol {
    func fetchDownloader(downloadType: RedditDownloader) -> RedditDownloaderProtocol
}

protocol RedditDownloaderProtocol {
    
}

enum RedditDownloader {
    case Post
    case UserIdentity
}
