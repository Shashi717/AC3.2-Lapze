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

class MainTabController: UITabBarController{
    
    private let profileVC = UINavigationController(rootViewController: ProfileViewController())
    private let activityVC = UINavigationController(rootViewController: ActivityViewController())
    private let leaderBoardVc = UINavigationController(rootViewController: LeaderBoardViewController())
    private let eventVC = UINavigationController(rootViewController: EventsViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dummyViewController: UIViewController = UIViewController()
        dummyViewController.view.backgroundColor = ColorPalette.greenThemeColor
        self.viewControllers = [dummyViewController]
        checkForUserStatus()
    }
    
    private func checkForUserStatus(){
        
        _ = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if user == nil{
                self.perform(#selector(self.showLogin), with: nil, afterDelay: 0.01)
            }else if self.userLocationPermissonGranted(){
                DispatchQueue.main.async {
                    self.setUpTabBar()
                }
            }
        })
        
        //        if FIRAuth.auth()?.currentUser != nil{
        //            self.setUpTabBar()
        //        }else{
        //            self.perform(#selector(self.showLogin), with: nil, afterDelay: 0.0001)
        //        }
    }
    
    private func userLocationPermissonGranted() -> Bool{
        LocationManager.sharedManager.requestWhenInUse()
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            print("Authorized when in use")
            return true
        case .authorizedAlways:
            print("Authorized always")
            return true
        case .denied:
            print("Denied")
            return false
        default:
            print("Default")
            return false
        }
    }
    
    @objc private func showLogin(){
        let loginVC = UINavigationController(rootViewController: LoginViewController())
        let dummyViewController: UIViewController = UIViewController()
        dummyViewController.view.backgroundColor = ColorPalette.greenThemeColor
        loginVC.modalTransitionStyle = .coverVertical
        self.viewControllers = [dummyViewController]
        present(loginVC, animated: true, completion: nil)
    }
    
    private func setUpTabBar(){

        self.viewControllers = [activityVC, profileVC, leaderBoardVc]
        
        let profileTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "Profile"), selectedImage: #imageLiteral(resourceName: "Profile"))
        profileTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        profileVC.tabBarItem = profileTab

        let leaderBoardTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "011-crown"), selectedImage: #imageLiteral(resourceName: "011-crown"))
        leaderBoardTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        leaderBoardVc.tabBarItem = leaderBoardTab
        
        let activityTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "home"), selectedImage: #imageLiteral(resourceName: "home"))
        activityTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        activityVC.tabBarItem = activityTab
        
        self.tabBar.backgroundColor = ColorPalette.greenThemeColor
        self.tabBar.barTintColor = .white
        self.tabBar.tintColor = ColorPalette.greenThemeColor
        
        self.selectedIndex = 0
    }
}
