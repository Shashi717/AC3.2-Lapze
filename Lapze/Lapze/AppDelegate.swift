//
//  AppDelegate.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/1/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyDOiTbYY-vEPH42OMTCp3nlmF4BtoVu7Cc")

        FIRApp.configure()

        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        //User Notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (allowd, error) in
            
        }
        
        UNUserNotificationCenter.current().delegate = self

        
        //Tab Init
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let navAppearance = UINavigationBar.appearance()
        navAppearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        navAppearance.barTintColor = ColorPalette.greenThemeColor
        
        
        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        let createEventVC = UINavigationController(rootViewController: CreateEventViewController())
        let eventsVC = UINavigationController(rootViewController: EventsViewController())
        let loginVC = UINavigationController(rootViewController: LoginViewController())
        let registerVC = UINavigationController(rootViewController: RegisterViewController())
        
        let tabs = UITabBarController()
        tabs.viewControllers = [eventsVC, profileVC, createEventVC, loginVC, registerVC]
        
        let profileTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "Profile"), selectedImage: #imageLiteral(resourceName: "Profile"))
        profileTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        profileVC.tabBarItem = profileTab
        
        let createEventTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "011-crown"), selectedImage: #imageLiteral(resourceName: "011-crown"))
        createEventTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        createEventVC.tabBarItem = createEventTab
        
        let eventsTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "home"), selectedImage: #imageLiteral(resourceName: "home"))
        eventsTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        eventsVC.tabBarItem = eventsTab
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 20.0),
                                                            NSForegroundColorAttributeName : UIColor.white]
        tabs.tabBar.backgroundColor = ColorPalette.greenThemeColor
        tabs.tabBar.barTintColor = .white
        tabs.tabBar.tintColor = ColorPalette.greenThemeColor
        
        tabs.selectedIndex = 0
        self.window?.rootViewController = tabs
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //
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

