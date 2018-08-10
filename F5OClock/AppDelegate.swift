//
//  AppDelegate.swift
//  F5OClock
//
//  Created by Daniel Yount on 10/13/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import UIKit
import OAuthSwift
import Swinject
import SwinjectStoryboard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let container = Container() { container in
        Container.loggingFunction = nil
        
        // MARK: Register Services
        container.register(AppContext.self) { _ in AppContext() }.inObjectScope(.container)
        container.register(AuthService.self) { r in
            let appContext = r.resolve(AppContext.self)!
            return RedditAuthService(appContext: appContext)
        }.inObjectScope(.container)
        container.register(RedditAPIService.self) { r in
            let authService = r.resolve(AuthService.self)!
            return RedditAPIService(authService: authService)
        }
        
        // MARK: Register Storyboards
        container.storyboardInitCompleted(RisingStoriesViewController.self) { (r, c) in
            c.redditAPIService = r.resolve(RedditAPIService.self)
        }
        container.storyboardInitCompleted(SettingsViewController.self) { (r, c) in
            c.appContext = r.resolve(AppContext.self)
            c.authService = r.resolve(AuthService.self)
        }
    }
    
    var isFirstLaunch: Bool {
        get { return UserDefaults.standard.bool(forKey: "IsFirstLaunch") }
        set { UserDefaults.standard.set(newValue, forKey: "IsFirstLaunch") }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        UserDefaults.standard.set(false, forKey: "RealTimeEnabled")
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = SwinjectStoryboard.create(name: "F5OClock", bundle: nil, container: container)
        self.window?.rootViewController = storyboard.instantiateInitialViewController()
        
        isFirstLaunch = true
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        let authService = container.resolve(AuthService.self)
        authService?.restoreAuthorizedUser()
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

        if (url.host == "oauthcallback") {
            OAuthSwift.handle(url: url)
        }
        return true
    }

}

