//
//  TodayViewController.swift
//  Top Story
//
//  Created by Daniel Yount on 3/2/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var upvoteLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    var redditPostDownloader = RedditPostDownloader()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        redditPostDownloader.downloadPosts {
            
            self.redditPostDownloader.sortPosts()
            self.titleLabel.text = self.redditPostDownloader.posts.first?.title
            self.commentLabel.text = "💬 \(self.redditPostDownloader.posts.first?.commentCount ?? 0)"
            self.upvoteLabel.text = "🔥 \(self.redditPostDownloader.posts.first?.upvotes ?? 0)"
            
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        redditPostDownloader.downloadPosts {
            
            self.redditPostDownloader.sortPosts()
            self.titleLabel.text = self.redditPostDownloader.posts.first?.title
            self.commentLabel.text = "💬 \(self.redditPostDownloader.posts.first?.commentCount ?? 0)"
            self.upvoteLabel.text = "🔥 \(self.redditPostDownloader.posts.first?.upvotes ?? 0)"
            
        }
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
