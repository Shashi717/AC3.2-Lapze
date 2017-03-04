//
//  AppDelegate.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/1/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        let createEventVC = UINavigationController(rootViewController: CreateEventViewController())
        let eventsVC = UINavigationController(rootViewController: EventsViewController())
        
        let tabs = UITabBarController()
        tabs.viewControllers = [profileVC, createEventVC, eventsVC]
        
        let profileTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "Profile"), selectedImage: #imageLiteral(resourceName: "Profile"))
        profileTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        profileVC.tabBarItem = profileTab
        
        let createEventTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "Profile"), selectedImage: #imageLiteral(resourceName: "Profile"))
        createEventTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        createEventVC.tabBarItem = createEventTab
        
        let eventsTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "Profile"), selectedImage: #imageLiteral(resourceName: "Profile"))
        eventsTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        eventsVC.tabBarItem = eventsTab
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 20.0),
                                                            NSForegroundColorAttributeName : UIColor.white]
        tabs.tabBar.backgroundColor = .gray
        tabs.tabBar.barTintColor = .blue
        tabs.tabBar.tintColor = .green
        
        tabs.selectedIndex = 0
        self.window?.rootViewController = tabs
        self.window?.makeKeyAndVisible()
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
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

