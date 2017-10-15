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
    
    // MARK: Properties
    
    var postDownloader = PostDownloader()
    let userDefaults = UserDefaults()
    let realTimeHandler = RealTimeRefreshHandler()
    var isRealTime = true
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Perform regular UI update for data
        updateUI()
        
        // Look for user settings for real time feature
        if userDefaults.bool(forKey: "RealTimeEnabled") == true {
            realTimeHandler.startTimer(viewController: self)
        }
        
        // Configure Navigation Bar
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        // Configure Refresh Control
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPostTableView(_ :)), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 0, green: 0.4624785185, blue: 0.7407966852, alpha: 1)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postDownloader.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostTableViewCell else { return UITableViewCell() }
        
        postDownloader.sortPosts()
        
        cell.backgroundColor = UIColor.white
        
        cell.titleLabel.text = postDownloader.posts[indexPath.row].title
        cell.upvoteCountLabel.text = "\(postDownloader.posts[indexPath.row].upvoteCount) 🔥"
        cell.commentCountLabel.text = "\(postDownloader.posts[indexPath.row].commentCount) 💬"
        
        if postDownloader.posts[indexPath.row].upvoteCount >= 50 {
            cell.backgroundColor = #colorLiteral(red: 0.997941792, green: 0.6387887001, blue: 0, alpha: 0.3379999995)
        }
        
        if postDownloader.posts[indexPath.row].upvoteCount >= 200 {
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
        }
        
        self.tableView.reloadData()
        
    }
    
    @objc private func refreshPostTableView(_ sender: Any) {
        
        DispatchQueue.main.async {
            self.updateUI()
            while self.postDownloader.downloaded == false {
                // Wait for data to be downloaded
            }
            
        }
        
        tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
}

