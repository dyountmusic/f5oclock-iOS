//
//  WebImageCache.swift
//  F5OClock
//
//  Created by Riley Williams on 11/14/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import UIKit

class WebImageCache : NSObject {
	var cachedImages:Dictionary<URL, UIImage> = Dictionary()
	var defaultImage = #imageLiteral(resourceName: "defaultThumbnail")
	
	func loadImageAsync(url: URL, completion: @escaping (UIImage) -> (Void)) {
		// Attempt to pull from cache
		if cachedImages[url] != nil {
			completion(cachedImages[url]!)
		}
		
		// Add uninitialized image/url to cache
		URLSession.shared.dataTask(with: url) { data, response, error in
			guard
				let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
				let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
				let data = data, error == nil,
				let image = UIImage(data: data)
				else {
					// Return the default image if the download fails.
					// The cache is not updated here, so the app will try to get
					// the failed image every time
					completion(self.defaultImage)
					return
			}
			
			self.cachedImages[url] = image
			completion(image)
		}.resume()
		
	}
	
}
