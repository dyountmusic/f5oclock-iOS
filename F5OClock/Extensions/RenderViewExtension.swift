//
//  RenderViewExtension.swift
//  F5OClock
//
//  Created by Riley Williams on 11/14/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import UIKit

extension UIImage {
	//preRendered==true is much faster, but the view must have already been rendered onscreen
	convenience init?(view: UIView, preRendered:Bool) {
		UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, view.contentScaleFactor)
		if preRendered {
			view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
		} else {
			view.layer.render(in: UIGraphicsGetCurrentContext()!) //should probably handle this more safely...
		}
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		self.init(cgImage: (image?.cgImage)!)
	}
}


