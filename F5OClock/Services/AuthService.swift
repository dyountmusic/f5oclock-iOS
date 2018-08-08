//
//  AuthService.swift
//  F5OClock
//
//  Created by Tim Miller on 8/5/18.
//  Copyright © 2018 Daniel Yount. All rights reserved.
//

import UIKit
import Foundation
import OAuthSwift

protocol AuthService {
    
    func authorizeUser(initiatingViewController: UIViewController, _ success: @escaping () -> ())
    
    func getAuthorizedClient(_ vc: UIViewController) -> OAuthSwiftClient?
    
    func restoreAuthorizedUser()
    
    func renewAccessToken(completionHandler: @escaping (Error?) -> Void)
    
    func logOut()
    
}
