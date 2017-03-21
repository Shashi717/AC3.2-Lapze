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
//import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Simulate Location
        //location()
        //Google Maps API Key
        GMSServices.provideAPIKey("AIzaSyDOiTbYY-vEPH42OMTCp3nlmF4BtoVu7Cc")
        //FireBase Init
        FIRApp.configure()
        
        
        //User Notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (allowd, error) in
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        //Styling
        UILabel.appearance().font = UIFont(name: "Heiti SC", size: 11.0)
        
        
        //MARK: - navbar
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let navAppearance = UINavigationBar.appearance()
        navAppearance.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir-Book", size: 16)!, NSForegroundColorAttributeName : UIColor.white]
        navAppearance.barTintColor = ColorPalette.darkPurple
        navAppearance.tintColor = .white
        
        //Root View
        //test
        self.window?.rootViewController = MainTabController()
        self.window?.makeKeyAndVisible()
        
        
        launchScreenSetup()
        animateFuncLogo()
        
        return true
    }
    
    
    //test
    var outerRing: UIImageView?
    var middleRing: UIImageView?
    var innerRing: UIImageView?
    var logoTitle: UIImageView?
    var customizedLaunchScreenView: UIView?
    
    func launchScreenSetup() {
        if let window = self.window {
            self.customizedLaunchScreenView = UIView(frame: window.bounds)
            self.customizedLaunchScreenView?.backgroundColor = ColorPalette.darkPurple
            self.window?.addSubview(self.customizedLaunchScreenView!)
            self.window?.bringSubview(toFront: self.customizedLaunchScreenView!)
            
            
            //add inits
            self.outerRing = UIImageView(frame: .zero)
            self.middleRing = UIImageView(frame: .zero)
            self.innerRing = UIImageView(frame: .zero)
            self.logoTitle = UIImageView(frame: .zero)
            
            self.outerRing?.image = #imageLiteral(resourceName: "outerRingw")
            self.middleRing?.image = #imageLiteral(resourceName: "middleRingw")
            self.innerRing?.image = #imageLiteral(resourceName: "innerRingw")
            self.logoTitle?.image = #imageLiteral(resourceName: "logoTitlew")
            
            //configure
            self.window?.addSubview(outerRing!)
            self.window?.addSubview(middleRing!)
            self.window?.addSubview(innerRing!)
            self.window?.addSubview(logoTitle!)
            
            outerRing?.snp.makeConstraints({ (view) in
                view.center.equalToSuperview()
            })
            middleRing?.snp.makeConstraints({ (view) in
                view.leading.equalTo(outerRing!)
                view.centerY.equalTo(outerRing!)
            })
            innerRing?.snp.makeConstraints({ (view) in
                view.leading.equalTo(outerRing!)
                view.centerY.equalTo(outerRing!)
            })
            logoTitle?.snp.makeConstraints({ (view) in
                view.center.equalTo(innerRing!)
            })
            
            
        }
    }
    
    
    func animateFuncLogo() {
        let duration = 2.0
        let delay = 0.0
        let options = UIViewKeyframeAnimationOptions.calculationModeLinear
        
        UIView.animateKeyframes(withDuration: duration, delay: delay, options: options, animations: {
            // within each keyframe the relativeStartTime and relativeDuration need to be values between 0.0 and 1.0
            
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration:  duration, animations: {
                self.outerRing?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4))
                self.middleRing?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4))
                self.innerRing?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4))
                //self.innerRing?.transform = CGAffineTransform(scaleX: 2, y: 2)
                
            })
            
            //            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration:  1/2 , animations: {
            //                self.logoTitle?.transform = CGAffineTransform(
            //
            //            })
            
            
            
            UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: {
                self.outerRing?.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.middleRing?.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.innerRing?.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
            
            
        }, completion: { finished in
            // any code entered here will be applied
            // once the animation has completed
            
            UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut,
                           animations: { () -> Void in
                            self.outerRing?.transform = CGAffineTransform(translationX: 0, y: -1000)
                            self.middleRing?.transform = CGAffineTransform(translationX: 0, y: -1000)
                            self.innerRing?.transform = CGAffineTransform(translationX: 0, y: -1000)
                            self.customizedLaunchScreenView?.alpha = 0
                            
                            
            },
                           completion: {_ in
                            
                            _ = [
                                self.customizedLaunchScreenView,
                                self.outerRing,
                                self.middleRing,
                                self.innerRing,
                                self.logoTitle
                                ].map { $0?.removeFromSuperview() }
            })
        })
        
        
        //return true
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }
    
    func location() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
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
        FirebaseManager.shared.removeEvent()
        FirebaseManager.shared.removeUserLocation()
    }
}

