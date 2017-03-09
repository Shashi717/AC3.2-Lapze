//
//  MainTabController.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/8/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreLocation

class MainTabController: UITabBarController,CLLocationManagerDelegate {
    
    let profileVC = UINavigationController(rootViewController: ProfileViewController())
    let createEventVC = UINavigationController(rootViewController: CreateEventViewController())
    let eventsVC = UINavigationController(rootViewController: EventsViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dummyViewController: UIViewController = UIViewController()
        dummyViewController.view.backgroundColor = ColorPalette.greenThemeColor
        self.viewControllers = [dummyViewController]
        checkForUserStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
    }
    
    private func checkForUserStatus(){
        
        _ = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if user == nil{
                self.perform(#selector(self.showLogin), with: nil, afterDelay: 0.0001)
            }else{
                DispatchQueue.main.async {
                    self.setUpTabBar()
                }
            }
        })
    }
    
    func checkLocationRequest(){
        
    }
    
    func showLogin(){
        let loginVC = UINavigationController(rootViewController: LoginViewController())
        let dummyViewController: UIViewController = UIViewController()
        dummyViewController.view.backgroundColor = ColorPalette.greenThemeColor
        loginVC.modalTransitionStyle = .crossDissolve
        self.viewControllers = [dummyViewController]
        present(loginVC, animated: true, completion: nil)
    }
    
    func handleUserSignIn(){
        
    }
    
    func setUpTabBar(){
        self.viewControllers = [eventsVC, profileVC, createEventVC]
        
        let profileTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "Profile"), selectedImage: #imageLiteral(resourceName: "Profile"))
        profileTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        profileVC.tabBarItem = profileTab
        
        let createEventTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "011-crown"), selectedImage: #imageLiteral(resourceName: "011-crown"))
        createEventTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        createEventVC.tabBarItem = createEventTab
        
        let eventsTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "home"), selectedImage: #imageLiteral(resourceName: "home"))
        eventsTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        eventsVC.tabBarItem = eventsTab
        
        self.tabBar.backgroundColor = ColorPalette.greenThemeColor
        self.tabBar.barTintColor = .white
        self.tabBar.tintColor = ColorPalette.greenThemeColor
        
        self.selectedIndex = 0
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status{
        case .authorizedAlways, .authorizedWhenInUse:
            print("All good")
            //            setUpTabBar()
            //manager.startUpdatingLocation()
            //manager.startMonitoringSignificantLocationChanges()
            
        case .denied, .restricted:
            print("NOPE")
            locman.requestAlwaysAuthorization()
            
        case .notDetermined:
            print("IDK")
            locman.requestAlwaysAuthorization()
        }
    }
    
    private let locman:CLLocationManager = {
        let locman = CLLocationManager()
        locman.desiredAccuracy = kCLLocationAccuracyBest
        return locman
    }()
}
