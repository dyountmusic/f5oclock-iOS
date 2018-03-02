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
    
    var redditPostDownloader = RedditPostDownloader()
    let userDefaults = UserDefaults()
    let realTimeHandler = RealTimePostRefreshFetcher()
    var isRealTime = true
    let refreshControl = UIRefreshControl()
	var imageCache = WebImageCache()
	var cellHeights: [IndexPath : CGFloat] = [:]
    
    
    // MARK: ViewController Functions
    
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
        
        if redditPostDownloader.posts.isEmpty {
            title = "No Posts To Fetch"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.title = "📈 \(RedditModel().subredditName.capitalized)"
        updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return redditPostDownloader.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostTableViewCell else { return UITableViewCell() }

        cell.backgroundColor = UIColor.white
        
        cell.titleLabel.text = redditPostDownloader.posts[indexPath.row].title
        cell.upvoteCountLabel.text = "\(redditPostDownloader.posts[indexPath.row].upvotes) 🔥"
        cell.commentCountLabel.text = "\(redditPostDownloader.posts[indexPath.row].upvotes) 💬"
        
        if redditPostDownloader.posts[indexPath.row].upvotes >= 50 {
            cell.backgroundColor = #colorLiteral(red: 0.997941792, green: 0.6387887001, blue: 0, alpha: 0.3379999995)
        }
        
        if redditPostDownloader.posts[indexPath.row].upvotes >= 200 {
            cell.backgroundColor = #colorLiteral(red: 0.8582192659, green: 0, blue: 0.05355661362, alpha: 0.3089999855)
        }

		// Load in images asyncronously
        guard let thumbnailURL = URL(string:redditPostDownloader.posts[indexPath.row].thumbnail) else {
            return cell
        }
        
		imageCache.loadImageAsync(url: thumbnailURL) { (image) -> (Void) in
			DispatchQueue.main.async() {
				cell.thumbnail.image = image
			}
		}

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let urlString = redditPostDownloader.posts[indexPath.row].url
        
        if let url = URL(string: urlString) {
            
            let vc = SFSafariViewController(url: url)
            
            if redditPostDownloader.posts[indexPath.row].upvotes >= 200 {
                vc.preferredControlTintColor = #colorLiteral(red: 0.8582192659, green: 0, blue: 0.05355661362, alpha: 1)
            } else if redditPostDownloader.posts[indexPath.row].upvotes >= 50 {
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
        let urlString = redditPostDownloader.posts[indexPath.row].url
        
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
		redditPostDownloader.downloadPosts() {
			DispatchQueue.main.sync {
                let animator = TableViewRowAnimator(originState: self.redditPostDownloader.previousState, targetState: self.redditPostDownloader.posts)
				self.tableView.performBatchUpdates({
					self.tableView.deleteRows(at: animator.deletions, with: .right)
					self.tableView.insertRows(at: animator.insertions, with: .left)
					for move in animator.moves {
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

