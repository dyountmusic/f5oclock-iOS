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
		//compute deletions
		for i in 0..<self.origin.count {
			let post = self.origin[i]
			if !self.target.contains(where: { (p:Post) -> Bool in p.hashValue == post }) {
				deletions.append(IndexPath(row: i, section: 0))
			}
		}
		
		//compute deletions and moves
		for i in 0..<self.target.count {
			let post = self.target[i]
			if !self.origin.contains(where: { (p:Int) -> Bool in p == post.hashValue }) {
				insertions.append(IndexPath(row: i, section: 0))
			} else {
				let from = self.origin.index(of: post.hashValue)!
				if i > from { //only move posts up, so only one animation is created per cell
					moves.append((from: IndexPath(row: from, section: 0), to: IndexPath(row: i, section: 0)))
				}
			}
		}
	}
}
