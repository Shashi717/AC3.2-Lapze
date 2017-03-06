//
//  EventsViewController.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/3/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit
import UserNotifications
import GoogleMaps

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
        //createPopup()
        createThumbView(userName: "noo")
        
        
    }

    func segementedControlValueChanged(sender: UISegmentedControl) {
        let segment = eventSegmentedControl.selectedSegmentIndex
        
        switch segment {
        case 0:
            print("\(events[0])")
            //thumbButton.setTitle("Join", for: .normal)
            self.navigationItem.title = "Current Events"
            thumbButton.setImage(UIImage(named: "Join3"), for: .normal)
            fillPopupForCreateEvent()
            
            
        case 1:
            print("\(events[1])")
            //thumbButton.setTitle("Challenge", for: .normal)
            self.navigationItem.title = "Challenge!"
            thumbButton.setImage(UIImage(named: "Challenge"), for: .normal)
            fillPopupForChallenge()
            fillMockupDataForThumbView()
        default:
            print("none")
        }
    }
    
    func fillPopupForCreateEvent() {
        popupContainerView.backgroundColor = ColorPalette.purpleThemeColor
        profileImageView.layer.borderColor = ColorPalette.orangeThemeColor.cgColor
        
        thumbStatContainerView.backgroundColor = ColorPalette.purpleThemeColor
        thumbProfileImageView.layer.borderColor = ColorPalette.orangeThemeColor.cgColor
    }
    
    func fillPopupForChallenge() {
        popupContainerView.backgroundColor = ColorPalette.orangeThemeColor
        profileImageView.layer.borderColor = ColorPalette.purpleThemeColor.cgColor
        
        thumbStatContainerView.backgroundColor = ColorPalette.orangeThemeColor
        thumbProfileImageView.layer.borderColor = ColorPalette.purpleThemeColor.cgColor
    }
    
    func fillMockupDataForThumbView() {
        thumbUserNameLabel.text = "CoolGuy123"
        thumbChallengeDescriptionLabel.text = "Bike Champ"
        thumbChallengeStatsLabel.text = "Ran 10 mile in 1 hr"
        
    }
    
    //MARK: - setup
    func createThumbView(userName: String) {
        self.view.addSubview(thumbStatContainerView)
        self.thumbStatContainerView.addSubview(thumbButton)
        self.thumbStatContainerView.addSubview(thumbProfileImageView)
        self.thumbStatContainerView.addSubview(thumbUserNameLabel)
        self.thumbStatContainerView.addSubview(thumbChallengeDescriptionLabel)
        self.thumbStatContainerView.addSubview(thumbChallengeStatsLabel)
        
        
        thumbStatContainerView.snp.makeConstraints { (view) in
            view.height.equalTo(130.0)
            view.width.equalTo(180.0)
            
            //should be changed to the location of the pin
            view.centerX.centerY.equalToSuperview()
        }
        thumbButton.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(4.0)
            view.right.equalToSuperview().inset(4.0)
            view.width.height.equalTo(40.0)
        }
        thumbProfileImageView.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(4.0)
            view.height.width.equalTo(50.0)
            view.centerX.equalToSuperview()
        }
        thumbUserNameLabel.snp.makeConstraints { (view) in
            view.top.equalTo(thumbProfileImageView.snp.bottom).offset(4.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(15.0)
        }
        thumbChallengeStatsLabel.snp.makeConstraints { (view) in
            view.left.right.equalToSuperview()
            view.bottom.equalToSuperview().inset(2.0)
            view.height.equalTo(15.0)
        }
        thumbChallengeDescriptionLabel.snp.makeConstraints { (view) in
            view.left.right.equalToSuperview()
            view.top.equalTo(thumbUserNameLabel.snp.bottom)
            view.bottom.equalTo(thumbChallengeStatsLabel.snp.top)
        }
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
    
    func thumbButtonTapped(sender: UIButton) {
        let selectedSegmentIndex = eventSegmentedControl.selectedSegmentIndex
        
        switch selectedSegmentIndex {
        case 0:
            print("Join Event")
            let content = UNMutableNotificationContent()
            content.title = "Join Event"
            content.subtitle = "Phoebe's event"
            content.body = "You are joining Phoebe's yoga session"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            let request = UNNotificationRequest(identifier: "event", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        case 1:
            print("Challenge Event")
        default:
            break
        }
    }
    
    //MARK: - Setup
    
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        self.view.addSubview(eventSegmentedControl)
        
    }
    
    func configureConstraints() {
        
        eventSegmentedControl.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(25.0)
            view.width.equalTo(160.0)
            view.height.equalTo(40.0)
            view.centerX.equalToSuperview()
        }
        
    }
    
    //MARK: - Views
    
    internal lazy var eventSegmentedControl: UISegmentedControl! = {
        var segmentedControl = UISegmentedControl()
        segmentedControl = UISegmentedControl(items: self.events)
        let font = UIFont.systemFont(ofSize: 14)
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        segmentedControl.tintColor = .white
        segmentedControl.backgroundColor = ColorPalette.purpleThemeColor
        segmentedControl.addTarget(self, action: #selector(segementedControlValueChanged(sender:)), for: .valueChanged)
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
    internal lazy var thumbStatContainerView: UIView! = {
        let view = UIView()
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = false
        return view
    }()
    internal lazy var thumbProfileImageView: UIImageView! = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25.0
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = false
        return imageView
    }()
    internal lazy var thumbUserNameLabel: UILabel! = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    internal lazy var thumbChallengeDescriptionLabel: UILabel! = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    internal lazy var thumbChallengeStatsLabel: UILabel! = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    internal lazy var thumbButton: UIButton! = {
        let button = UIButton()
       // button.titleLabel!.font =  UIFont(name: "System - System", size: 5)
       // button.backgroundColor = ColorPalette.logoGreenColor
//        button.layer.cornerRadius = 10.0
//        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(thumbButtonTapped(sender:)), for: .touchUpInside)
        return button
    }()
    
}
