//
//  EventsViewController.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/3/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit


public enum Event: String {
    case currentEvents = "Events"
    case challenges = "Challenges"
}

class EventsViewController: UIViewController {
    
    let events: [Event.RawValue] = [Event.currentEvents.rawValue, Event.challenges.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        setupViewHierarchy()
        configureConstraints()
        createChallengePopup()
    }
    
    func createChallengePopup() {
       
        self.view.addSubview(challengePopupContainerView)
        self.challengePopupContainerView.addSubview(profileImageView)
        self.challengePopupContainerView.addSubview(challengeStatsLabel)
        self.challengePopupContainerView.addSubview(challengeDescriptionLabel)
        
        
        challengePopupContainerView.snp.makeConstraints { (view) in
            view.centerX.centerY.equalToSuperview()
            view.height.width.equalTo(200.0)
        }
        profileImageView.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(16.0)
            view.height.width.equalTo(75.0)
            view.centerX.equalToSuperview()
        }
        challengeStatsLabel.snp.makeConstraints { (view) in
            view.left.right.bottom.equalToSuperview()
            view.height.equalTo(10.0)
        }
        challengeDescriptionLabel.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.width.equalTo(160.0)
            view.top.equalTo(profileImageView.snp.bottom).offset(8.0)
            view.bottom.equalTo(challengeStatsLabel.snp.top).inset(8.0)
        }
    }
    
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        self.view.addSubview(eventSegmentedControl)
        
    }
    
    func configureConstraints() {
        
        eventSegmentedControl.snp.makeConstraints { (view) in
            view.width.equalTo(160.0)
            view.height.equalTo(40.0)
            view.centerX.equalToSuperview()
            view.top.equalToSuperview().offset(16.0)
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
    
    
    internal lazy var eventSegmentedControl: UISegmentedControl = {
        var segmentedControl = UISegmentedControl()
        segmentedControl = UISegmentedControl(items: self.events)
        let font = UIFont.systemFont(ofSize: 14)
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        segmentedControl.tintColor = .white
        segmentedControl.backgroundColor = ColorPalette.purpleThemeColor
        return segmentedControl
    }()
    internal lazy var challengePopupContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.orangeThemeColor
        return UIView()
    }()
    internal lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    internal lazy var challengeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    internal lazy var challengeStatsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
}
