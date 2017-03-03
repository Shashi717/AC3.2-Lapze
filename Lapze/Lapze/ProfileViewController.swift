//
//  ProfileViewController.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/3/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit

class ProfileViewController: UIViewController {
    
    let segments = ["Create", "Challenge"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        setupViewHierarchy()
        configureConstraints()
        fillMockData()
        
    }
    
    
    
    
    func fillMockData() {
        
        profileImageView.image = UIImage(named: "mock_profile_pic")
        
    }
    
    
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    internal lazy var profileImageView: UIImageView! = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 75.0
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.purple.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()
    internal lazy var eventSegmentedControl: UISegmentedControl! = {
        var segmentedControl = UISegmentedControl()
        segmentedControl = UISegmentedControl(items: self.segments)
        let font = UIFont.systemFont(ofSize: 20)
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        segmentedControl.tintColor = .white
        segmentedControl.backgroundColor = .purple
        return segmentedControl
    }()
    internal lazy var usernameLabel: UILabel! = {
        let label = UILabel()
        return label
    }()
    internal lazy var userRankLabel: UILabel! = {
        let label = UILabel()
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
}
