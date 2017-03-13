//
//  PopupViewController.swift
//  Lapze
//
//  Created by Ilmira Estil on 3/6/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth
import CoreLocation

protocol JoinActivityDelegate {
    func joinChallenge(user: String, challengeId: String)
    func actionButtonTapped(didCreateActivity: Bool)
}

class PopupViewController: UIViewController {
    
    var segment: Int?
    var delegate: JoinActivityDelegate?
    var userId: String = ""
    var activityId: String = ""
    var didCreateActivity = false
    var userLocation: CLLocation?
    
    var challengeLocation: Location?
    let locationStore = LocationStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        
        //tap gesture
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dissmissView))
        view.addGestureRecognizer(tap)
        setupViewHierarchy()
        configureConstraints()
        
        fillPopupForChallenge()
        
        //switch
        if segment == 0 {
            self.actionButton.backgroundColor = ColorPalette.purpleThemeColor
            self.popupContainerView.backgroundColor = ColorPalette.purpleThemeColor
        } else {
            self.actionButton.backgroundColor = ColorPalette.orangeThemeColor
            self.popupContainerView.backgroundColor = ColorPalette.orangeThemeColor
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isBeingDismissed {
            self.clearData()
        }
        
    }
    
    func dissmissView() {
        if didCreateActivity == false {
            dismissPopup()
            
        }
    }
    
    //MARK: - Utilities
    func fillPopupForChallenge() {
        popupContainerView.backgroundColor = ColorPalette.orangeThemeColor
        profileImageView.layer.borderColor = ColorPalette.purpleThemeColor.cgColor
    }
    
    
    func dismissPopup() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func startActivity() {
        
        if segment == 0 {
            
        }
        else {
            if let id = FIRAuth.auth()?.currentUser?.uid {
                self.userId = id
            }
            if didCreateActivity == true {
                self.delegate?.actionButtonTapped(didCreateActivity: didCreateActivity)
                dismissPopup()
            }
            else {
                
                let location = Location(lat: self.challengeLocation!.lat, long: self.challengeLocation!.long)
                if self.locationStore.isUserWithinRadius(userLocation:userLocation!, challengeLocation:location) {
                    print("User is within the radius")
                    self.delegate?.joinChallenge(user: userId, challengeId: activityId)
                    dismissPopup()
                }
                else {
                    print("User is NOT within the radius")
                    let alertController = showAlert(title: "Unsuccessful!", message: "You're not at the challenge starting point!", useDefaultAction: true)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    func clearData() {
        self.challengeNameLabel.text = nil
        self.challengeDescriptionLabel.text = nil
        self.challengeStatsLabel.text = nil
    }
    
    //MARK: - setup
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        self.view.addSubview(blurView)
        self.blurView.addSubview(popupContainerView)
        self.blurView.addSubview(actionButton)
        self.popupContainerView.addSubview(profileImageView)
        self.popupContainerView.addSubview(challengeNameLabel)
        self.popupContainerView.addSubview(challengeDescriptionLabel)
        self.popupContainerView.addSubview(challengeStatsLabel)
    }
    
    func configureConstraints() {
        popupContainerView.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.35)
            view.width.equalToSuperview().multipliedBy(0.75)
        }
        
        profileImageView.snp.makeConstraints { (view) in
            view.height.width.equalTo(100.0)
            view.centerY.equalTo(popupContainerView.snp.top)
        }
        
        challengeNameLabel.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(25.0)
            view.left.equalToSuperview().offset(8.0)
            view.right.equalToSuperview().inset(8.0)
        }
        
        challengeDescriptionLabel.snp.makeConstraints { (view) in
            view.top.equalTo(challengeNameLabel.snp.bottom).offset(25.0)
            view.left.equalToSuperview().offset(8.0)
            view.right.equalToSuperview().inset(8.0)
        }
        
        challengeStatsLabel.snp.makeConstraints { (view) in
            view.top.equalTo(challengeDescriptionLabel.snp.bottom).offset(25.0)
            view.left.equalToSuperview().offset(8.0)
            view.right.equalToSuperview().inset(8.0)
            view.bottom.equalToSuperview().inset(25.0)
        }
        
        actionButton.snp.makeConstraints { (view) in
            view.bottom.equalToSuperview().inset(50)
            view.width.equalToSuperview()
            view.height.equalTo(50)
        }
        
    }
    
    //MARK: - Views
    internal lazy var popupContainerView: UIView! = {
        let view = UIView()
        view.layer.cornerRadius = 15.0
        view.layer.masksToBounds = false
        return view
    }()
    
    internal lazy var profileImageView: UIImageView! = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 40.0
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "004-boy")
        //imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = false
        return imageView
    }()
    
    internal lazy var challengeNameLabel: UILabel! = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    internal lazy var challengeDescriptionLabel: UILabel! = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping // or NSLineBreakMode.ByWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    internal lazy var challengeStatsLabel: UILabel! = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    internal lazy var blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurView
    }()
    
    internal lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.addTarget(self, action: #selector(startActivity), for: .touchUpInside)
        return button
    }()
    
    
}

