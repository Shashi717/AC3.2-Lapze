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
        
        navigationController?.navigationBar.barTintColor = ColorPalette.greenThemeColor
        self.view.backgroundColor = .white
        setupViewHierarchy()
        configureConstraints()
        //createPopup()
        //fillPopupForChallenge()
    
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func fillPopupForCreateEvent() {
        popupContainerView.backgroundColor = ColorPalette.purpleThemeColor
        profileImageView.layer.borderColor = ColorPalette.orangeThemeColor.cgColor
    }
    
    func fillPopupForChallenge() {
        popupContainerView.backgroundColor = ColorPalette.orangeThemeColor
        profileImageView.layer.borderColor = ColorPalette.purpleThemeColor.cgColor
    }
    
    func createPopup() {
        
        self.view.addSubview(popupContainerView)
        self.popupContainerView.addSubview(profileImageView)
        self.popupContainerView.addSubview(challengeStatsLabel)
        self.popupContainerView.addSubview(challengeDescriptionLabel)
        
        popupContainerView.snp.makeConstraints { (view) in
            view.centerX.centerY.equalToSuperview()
            view.height.equalTo(200.0)
            view.width.equalTo(250.0)
        }
        profileImageView.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(16.0)
            view.height.width.equalTo(70.0)
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

    internal lazy var eventSegmentedControl: UISegmentedControl! = {
        var segmentedControl = UISegmentedControl()
        segmentedControl = UISegmentedControl(items: self.events)
        let font = UIFont.systemFont(ofSize: 14)
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        segmentedControl.tintColor = .white
        segmentedControl.backgroundColor = ColorPalette.purpleThemeColor
        return segmentedControl
    }()
    internal lazy var popupContainerView: UIView! = {
        let view = UIView()
        view.layer.cornerRadius = 15.0
        view.layer.masksToBounds = false
        return view
    }()
    internal lazy var profileImageView: UIImageView! = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 35.0
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = false
        return imageView
    }()
    internal lazy var challengeDescriptionLabel: UILabel! = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    internal lazy var challengeStatsLabel: UILabel! = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
}
