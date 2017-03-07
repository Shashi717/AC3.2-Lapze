//
//  ProfileViewController.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/3/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    let segments = ["Create Event", "Create Challenge"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "My Profile"
        self.view.backgroundColor = .white
        setupViewHierarchy()
        configureConstraints()
        fillMockData()
    }
    
    
    
    func fillMockData() {
        
        profileImageView.image = UIImage(named: "mock_profile_pic")
        usernameLabel.text = "CoolGuy123"
        userRankLabel.text = "Rank: 321"
        activitiesLabel.text = "Activities: Biking, Running"
        challengesLabel.text = "Challenges: Running"
        
        
    }
    
    func segementedControlValueChanged(sender: UISegmentedControl) {
        let segment = eventSegmentedControl.selectedSegmentIndex
        
        switch segment {
        case 0:
            print("\(segments[0])")
            let createEventVc = CreateEventViewController()
        //self.show(createEventVc, sender: self)
        case 1:
            print("\(segments[1])")
        default:
            print("none")
        }
    }
    
    func logoutButtonTapped(sender: UIBarButtonItem) {
        do {
            try? FIRAuth.auth()?.signOut()
            let alertController = showAlert(title: "Logout Successful!", message: "You have logged out successfully. Please log back in if you want to enjoy the features.", useDefaultAction: true)
            self.present(alertController, animated: true, completion: nil)
        }
        catch
        {
            let alertController = showAlert(title: "Logout Unsuccessul!", message: "Error occured. Please try again.", useDefaultAction: true)
            self.present(alertController, animated: true, completion: nil)

        }
        
    }
    
    //MARK: - setup
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        
        navigationItem.rightBarButtonItem = logoutButton
        self.view.addSubview(profileImageView)
        self.view.addSubview(usernameLabel)
        self.view.addSubview(userRankLabel)
        self.view.addSubview(activitiesLabel)
        self.view.addSubview(challengesLabel)
        self.view.addSubview(eventSegmentedControl)
    }
    
    func configureConstraints() {
        
        profileImageView.snp.makeConstraints { (view) in
            view.width.height.equalTo(150.0)
            view.top.equalToSuperview().inset(8.0)
            view.centerX.equalToSuperview()
        }
        usernameLabel.snp.makeConstraints { (view) in
            view.top.equalTo(profileImageView.snp.bottom).offset(8.0)
            view.centerX.equalToSuperview()
            view.left.equalToSuperview().offset(8.0)
            view.right.equalToSuperview().inset(8.0)
            view.height.equalTo(20.0)
        }
        userRankLabel.snp.makeConstraints { (view) in
            view.top.equalTo(usernameLabel.snp.bottom).offset(8.0)
            view.left.equalToSuperview().offset(8.0)
            view.right.equalToSuperview().inset(8.0)
            view.height.equalTo(20.0)
        }
        activitiesLabel.snp.makeConstraints { (view) in
            view.top.equalTo(userRankLabel.snp.bottom).offset(16.0)
            view.left.equalToSuperview().offset(8.0)
            view.right.equalToSuperview().inset(8.0)
            view.height.equalTo(50.0)
        }
        challengesLabel.snp.makeConstraints { (view) in
            view.top.equalTo(activitiesLabel.snp.bottom).offset(16.0)
            view.left.equalToSuperview().offset(8.0)
            view.right.equalToSuperview().inset(8.0)
            view.height.equalTo(50.0)
        }
        eventSegmentedControl.snp.makeConstraints { (view) in
            view.bottom.equalToSuperview()
            view.left.equalToSuperview()
            view.right.equalToSuperview()
            view.height.equalTo(50.0)
        }
    }
    
    //MARK: - Views
    internal lazy var profileImageView: UIImageView! = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 75.0
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = ColorPalette.purpleThemeColor.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()
    internal lazy var eventSegmentedControl: UISegmentedControl! = {
        var segmentedControl = UISegmentedControl()
        segmentedControl = UISegmentedControl(items: self.segments)
        let font = UIFont.systemFont(ofSize: 20)
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        segmentedControl.tintColor = .white
        segmentedControl.backgroundColor = ColorPalette.purpleThemeColor
        segmentedControl.addTarget(self, action: #selector(segementedControlValueChanged(sender:)), for: .valueChanged)
        return segmentedControl
    }()
    internal lazy var usernameLabel: UILabel! = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    internal lazy var userRankLabel: UILabel! = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    internal lazy var activitiesLabel: UILabel! = {
        let label = UILabel()
        return label
    }()
    internal lazy var challengesLabel: UILabel! = {
        let label = UILabel()
        return label
    }()
    internal lazy var logoutButton: UIBarButtonItem! = {
        var barButton = UIBarButtonItem()
        barButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logoutButtonTapped(sender:)))
        return barButton
    }()
    
}
