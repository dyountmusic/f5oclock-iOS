//
//  ViewController.swift
//  F5OClock
//
//  Created by Daniel Yount on 10/13/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import UIKit

class TopStoryViewController: UIViewController, UITableViewDataSource {
    
    //MARK: Interface Builder Properties
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var upvoteCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var thumbnail: UIImageView!

    
    // MARK: Properties
    
    var postDownloader = PostDownloader()
    let userDefaults = UserDefaults()
    let realTimeHandler = RealTimeRefreshHandler()
    var isRealTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        
        if userDefaults.bool(forKey: "RealTimeEnabled") == true {
            realTimeHandler.startTimer(viewController: self)
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Interface Builder Actions
    
    @IBAction func refreshTopStory(_ sender: Any) {
        
        updateUI()
        
    }
    
    // MARK: TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postDownloader.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostTableViewCell else { return UITableViewCell() }
        
        postDownloader.sortPosts()
        
        cell.titleLabel.text = postDownloader.posts[indexPath.row].title
        cell.upvoteCountLabel.text = "\(postDownloader.posts[indexPath.row].upvoteCount) upvotes."
        cell.commentCountLabel.text = "\(postDownloader.posts[indexPath.row].commentCount) comments."
        
        if postDownloader.posts[indexPath.row].upvoteCount >= 20 {
            cell.backgroundColor = #colorLiteral(red: 0.997941792, green: 0.6387887001, blue: 0, alpha: 0.3379999995)
        }
        
        if postDownloader.posts[indexPath.row].upvoteCount >= 50 {
            cell.backgroundColor = #colorLiteral(red: 0.8582192659, green: 0, blue: 0.05355661362, alpha: 0.3089999855)
        }
        
        if postDownloader.posts[indexPath.row].thumbnail == "default" || postDownloader.posts[indexPath.row].thumbnail == "self" {
            cell.thumbnail.image = #imageLiteral(resourceName: "defaultThumbnail.png")
        }
        
        let thumbnailURL = postDownloader.posts[indexPath.row].thumbnail
        cell.thumbnail.downloadedFrom(link: thumbnailURL)
        
        return cell
    }
    
    // MARK: Functions
    
    func updateUI() {
        
        if userDefaults.bool(forKey: "RealTimeEnabled") == false {
            realTimeHandler.stopTimer()
            isRealTime = false
        }
        
        if userDefaults.bool(forKey: "RealTimeEnabled") == true && isRealTime == false {
            realTimeHandler.startTimer(viewController: self)
            isRealTime = true
        }
        
        postDownloader.downloadPosts()
        
        while postDownloader.downloaded == false {
            // Waiting until the data is downloaded to execute the next line
            //imageActivityIndicator.isHidden = false
        }
        
        self.tableView.reloadData()
        
    }
    
}

