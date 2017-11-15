//
//  ViewController.swift
//  F5OClock
//
//  Created by Daniel Yount on 10/13/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import UIKit
import SafariServices

class RisingStoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerPreviewingDelegate {
    
    //MARK: Interface Builder Properties
    @IBOutlet var tableView: UITableView!
    
    // MARK: Properties
    
    var postDownloader = PostDownloader()
    let userDefaults = UserDefaults()
    let realTimeHandler = RealTimeRefreshHandler()
    var isRealTime = true
    let refreshControl = UIRefreshControl()
	var imageCache = WebImageCache()
	var cellHeights: [IndexPath : CGFloat] = [:]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Register for 3D touch Peak and Pop
        if (traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: view)
        }
        
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

		// Load in images asyncronously
		let thumbnailURL = URL(string:postDownloader.posts[indexPath.row].thumbnail)!
		imageCache.loadImageAsync(url: thumbnailURL) { (image) -> (Void) in
			DispatchQueue.main.async() {
				cell.thumbnail.image = image
			}
		}

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let urlString = postDownloader.posts[indexPath.row].url
        
        if let url = URL(string: urlString) {
            
            let vc = SFSafariViewController(url: url)
            
            if postDownloader.posts[indexPath.row].upvoteCount >= 200 {
                vc.preferredControlTintColor = #colorLiteral(red: 0.8582192659, green: 0, blue: 0.05355661362, alpha: 1)
            } else if postDownloader.posts[indexPath.row].upvoteCount >= 50 {
                vc.preferredControlTintColor = #colorLiteral(red: 0.997941792, green: 0.6387887001, blue: 0, alpha: 1)
            } else {
                vc.preferredControlTintColor = #colorLiteral(red: 0, green: 0.4624785185, blue: 0.7407966852, alpha: 1)
            }
            
            present(vc, animated: true)
        }
    }
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cellHeights[indexPath] = cell.frame.size.height
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let height = cellHeights[indexPath] else { return 100.0 }
		return height
	}
	
    // MARK: Peak and Pop Functions
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        let urlString = postDownloader.posts[indexPath.row].url
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        let vc = SFSafariViewController(url: url)
        vc.preferredContentSize = CGSize(width: 0.0, height: 600)
        previewingContext.sourceRect = cell.frame
        return vc
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        present(viewControllerToCommit, animated: true)
    }
    
    
    // MARK: Functions
    
    func updateUI() {
		if self.refreshControl.isRefreshing {
			return
		}
		
        if userDefaults.bool(forKey: "RealTimeEnabled") == false {
            realTimeHandler.stopTimer()
            isRealTime = false
        }
        
        if userDefaults.bool(forKey: "RealTimeEnabled") == true && isRealTime == false {
            realTimeHandler.startTimer(viewController: self)
            isRealTime = true
        }

		
		// Reload table view data after all posts have been downloaded without blocking thread
		self.refreshControl.beginRefreshing()
		postDownloader.downloadPosts() {
			DispatchQueue.main.sync {
				var deletions = [IndexPath]()
				var insertions = [IndexPath]()
				var moves = [(from:IndexPath, to:IndexPath)]()
				
				//compute deletions
				for i in 0..<self.postDownloader.previousState.count {
					let post = self.postDownloader.previousState[i]
					if !self.postDownloader.posts.contains(where: { (p:Post) -> Bool in p.hashValue == post }) {
						deletions.append(IndexPath(row: i, section: 0))
					}
				}
				
				//compute deletions and moves
				for i in 0..<self.postDownloader.posts.count {
					let post = self.postDownloader.posts[i]
					if !self.postDownloader.previousState.contains(where: { (p:Int) -> Bool in p == post.hashValue }) {
						insertions.append(IndexPath(row: i, section: 0))
					} else {
						let from = self.postDownloader.previousState.index(of: post.hashValue)!
						if i > from { //only move posts up, so only one animation is created per cell
							moves.append((from: IndexPath(row: from, section: 0), to: IndexPath(row: i, section: 0)))
						}
					}
				}
				
				self.tableView.performBatchUpdates({
					self.tableView.deleteRows(at: deletions, with: .right)
					self.tableView.insertRows(at: insertions, with: .left)
					for move in moves {
						self.tableView.moveRow(at: move.from, to: move.to)
					}
				}, completion: { (_) in
					self.tableView.reloadData()
					//delay end of refresh animation for maximum satisfaction
					Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false){ (_) in
						self.refreshControl.endRefreshing()
					}
				})
			}
		}
		
	}
    
    @objc private func refreshPostTableView(_ sender: Any) {
		self.refreshControl.endRefreshing()
		updateUI()
    }
    
}

