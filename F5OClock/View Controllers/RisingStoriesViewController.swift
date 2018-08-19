//
//  ViewController.swift
//  F5OClock
//
//  Created by Daniel Yount on 10/13/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import UIKit
import SafariServices

class RisingStoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerPreviewingDelegate, RedditUserActionDelegate {
    
    //MARK: Interface Builder Properties
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: Properties
    
    let redditPostFetcher = RedditPostDownloadService()
    let realTimePostRefreshService = RealTimePostRefreshFetcher()
    let imageCache = WebImageCache()
    
    public var redditAPIService: RedditAPIService?
    
    var isRealTime: Bool {
        get { return UserDefaults.standard.bool(forKey: "RealTimeEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "RealTimeEnabled") }
    }
    
    var isFirstLaunch: Bool {
        get { return UserDefaults.standard.bool(forKey: "IsFirstLaunch") }
        set { UserDefaults.standard.set(newValue, forKey: "IsFirstLaunch") }
    }
    
    let refreshControl = UIRefreshControl()

	var cellHeights: [IndexPath : CGFloat] = [:]
    
    // MARK: ViewController Functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Register for 3D touch Peak and Pop
        if (traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: view)
        }
        
        // Perform regular UI update for data
        navigationController?.navigationBar.prefersLargeTitles = true
        updateUI()
        
        // Look for user settings for real time feature
        if isRealTime || isFirstLaunch {
            realTimePostRefreshService.startTimer(viewController: self)
        }
        
        // Configure Refresh Control
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPostTableView(_ :)), for: .valueChanged)
        
        if redditPostFetcher.posts.isEmpty {
            title = "No Posts To Fetch"
        }
        
        isFirstLaunch = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.title = "\(RedditMetaModel().subredditName.capitalized)"
        updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return redditPostFetcher.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostTableViewCell else { return UITableViewCell() }

        cell.backgroundColor = UIColor.white
        
        cell.titleLabel.text = redditPostFetcher.posts[indexPath.row].title
        cell.upvoteCountLabel.text = "\(redditPostFetcher.posts[indexPath.row].upvotes)"
        cell.commentCountLabel.text = "\(redditPostFetcher.posts[indexPath.row].commentCount)"
        cell.link = redditPostFetcher.posts[indexPath.row].url
        
        if redditPostFetcher.posts[indexPath.row].upvotes >= 100 {
            cell.backgroundColor = #colorLiteral(red: 0.997941792, green: 0.6387887001, blue: 0, alpha: 0.3379999995)
        }
        
        if redditPostFetcher.posts[indexPath.row].upvotes >= 250 {
            cell.backgroundColor = #colorLiteral(red: 1, green: 0.3659999967, blue: 0.2240000069, alpha: 0.3140000105)
        }
        
        if redditPostFetcher.posts[indexPath.row].upvotes >= 500 {
            cell.backgroundColor = #colorLiteral(red: 0.8582192659, green: 0, blue: 0.05355661362, alpha: 0.3089999855)
        }

		// Load in images asyncronously
        guard let thumbnailURL = URL(string:redditPostFetcher.posts[indexPath.row].thumbnail) else {
            return cell
        }
        
        imageCache.loadImageAsync(url: thumbnailURL) { (image) -> (Void) in
            DispatchQueue.main.async() {
                cell.thumbnail.image = image
            }
        }
        
        cell.redditUserActionDelegate = self
        cell.redditPost = self.redditPostFetcher.posts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let urlString = redditPostFetcher.posts[indexPath.row].url
        
        let config = SFSafariViewController.Configuration.init()
        config.entersReaderIfAvailable = true
        
        if let url = URL(string: urlString) {
            let vc = SFSafariViewController(url: url, configuration: config)
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
        let urlString = redditPostFetcher.posts[indexPath.row].url
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        let config = SFSafariViewController.Configuration.init()
        config.entersReaderIfAvailable = true
        
        let vc = SFSafariViewController(url: url, configuration: config)
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
		
        if !isRealTime {
            realTimePostRefreshService.stopTimer()
        }
        
        if isRealTime {
            realTimePostRefreshService.startTimer(viewController: self)
        }

		// Reload table view data after all posts have been downloaded without blocking thread
		self.refreshControl.beginRefreshing()
		redditPostFetcher.downloadPosts() {
			DispatchQueue.main.sync {
                let animator = TableViewRowAnimator(originState: self.redditPostFetcher.previousState, targetState: self.redditPostFetcher.posts)
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
    
    func updateUIWithoutRefreshControl() {
        redditPostFetcher.downloadPosts() {
            DispatchQueue.main.sync {
                let animator = TableViewRowAnimator(originState: self.redditPostFetcher.previousState, targetState: self.redditPostFetcher.posts)
                self.tableView.performBatchUpdates({
                    self.tableView.deleteRows(at: animator.deletions, with: .right)
                    self.tableView.insertRows(at: animator.insertions, with: .left)
                    for move in animator.moves {
                        self.tableView.moveRow(at: move.from, to: move.to)
                    }
                })
                self.tableView.reloadData()
            }
        }
    }
    
    func upvote(_ id: String, type: String) {
        self.redditAPIService?.upvotePost(id: id, type: type)
    }
    
    func downvote(_ id: String, type: String) {
        self.redditAPIService?.downVotePost(id: id, type: type)
    }
        
    @objc private func refreshPostTableView(_ sender: Any) {
        self.refreshControl.endRefreshing()
        updateUI()
    }
    
}

