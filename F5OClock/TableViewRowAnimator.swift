//
//  TableViewRowAnimator.swift
//  F5OClock
//
//  Created by Riley Williams on 11/15/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import UIKit

class TableViewRowAnimator {
	
	var origin:[Int]
	var target:[Post]
	var deletions = [IndexPath]()
	var insertions = [IndexPath]()
	var moves = [(from:IndexPath, to:IndexPath)]()
	
	required init(originState origin:[Int], targetState target:[Post]) {
		self.origin = origin
		self.target = target
		self.computeAnimation()
	}
	func computeAnimation() {
		// Convert target [Post] to hashValue [Int] to match origin (performance)
		var goal = target.map { (post) -> Int in
			return post.hashValue
		}
		
		// Compute deletions
		for i in 0..<origin.count {
			if !goal.contains(origin[i]) {
				deletions.append(IndexPath(row: i, section: 0))
			}
		}
		
		// Compute insertions
		for i in 0..<goal.count {
			if !origin.contains(goal[i]) {
				insertions.append(IndexPath(row: i, section: 0))
			}
		}
		
		// Compute moves
		for i in 0..<goal.count {
			let post = goal[i]
			if origin.contains(post) {
				let from = origin.index(of: post)!
				if from - i > 0 {
					moves.append((from: IndexPath(row: from, section: 0), to: IndexPath(row: i, section: 0)))
				}
			}
		}
		
	}
	
}
