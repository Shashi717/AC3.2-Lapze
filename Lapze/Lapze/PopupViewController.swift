//
//  PopupViewController.swift
//  Lapze
//
//  Created by Ilmira Estil on 3/6/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit

class PopupViewController: UIViewController {
    var segment: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        //tap gesture
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        view.addGestureRecognizer(tap)
        setupViewHierarchy()
        configureConstraints()
        
        //popup data
        fillMockupData()
        fillPopupForChallenge()
        
        //switch
        if segment == 0 {
            print("segment: \(segment)")
            self.actionButton.backgroundColor = ColorPalette.purpleThemeColor
            self.popupContainerView.backgroundColor = ColorPalette.purpleThemeColor
        } else {
            print("segment: \(segment)")
            self.actionButton.backgroundColor = ColorPalette.orangeThemeColor
            self.popupContainerView.backgroundColor = ColorPalette.orangeThemeColor
        }
    }
    
    //MARK: - Utilities
    func fillPopupForChallenge() {
        popupContainerView.backgroundColor = ColorPalette.orangeThemeColor
        profileImageView.layer.borderColor = ColorPalette.purpleThemeColor.cgColor
    }
    
    func fillMockupData() {
        userNameLabel.text = "CoolGuy123"
        challengeDescriptionLabel.text = "Bike Champ"
        challengeStatsLabel.text = "Ran 10 mile in 1 hr"
    }
    
    
    
    //MARK: - setup
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        self.view.addSubview(blurView)
        self.blurView.addSubview(popupContainerView)
        self.blurView.addSubview(actionButton)
        self.popupContainerView.addSubview(profileImageView)
        self.popupContainerView.addSubview(challengeStatsLabel)
        self.popupContainerView.addSubview(userNameLabel)
        self.popupContainerView.addSubview(challengeDescriptionLabel)
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
        
        userNameLabel.snp.makeConstraints { (view) in
            view.top.equalTo(profileImageView.snp.bottom).offset(4.0)
            view.height.equalTo(15.0)
            view.centerX.equalToSuperview()
        }
        
        challengeDescriptionLabel.snp.makeConstraints { (view) in
            view.top.equalTo(userNameLabel.snp.bottom)
            view.bottom.equalTo(challengeStatsLabel.snp.top)
            view.centerX.equalToSuperview()
        }
        
        challengeStatsLabel.snp.makeConstraints { (view) in
            view.bottom.equalToSuperview().inset(2.0)
            view.height.equalTo(15.0)
            view.centerX.equalToSuperview()
        }
        
        actionButton.snp.makeConstraints { (view) in
            view.bottom.equalToSuperview().inset(50)
            view.width.equalToSuperview()
            view.height.equalTo(50)
        }
        
    }
    
    func dismissPopup() {
        print("dismiss popup")
        self.dismiss(animated: true, completion: nil)
    }
    
    func startActivity() {
        print("join/start button")
        
    }
    
    //MARK: - Views
    internal lazy var popupContainerView: UIView! = {
        let view = UIView()
        view.layer.cornerRadius = 15.0
        view.layer.masksToBounds = false
        view.backgroundColor = ColorPalette.purpleThemeColor
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
    
    internal lazy var userNameLabel: UILabel! = {
        let label = UILabel()
        label.textColor = .white
        return label
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
    
    internal lazy var blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurView
    }()
    
    internal lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Join/Start", for: .normal)
        button.addTarget(self, action: #selector(startActivity), for: .touchUpInside)
        button.backgroundColor = ColorPalette.purpleThemeColor
        return button
    }()
    
    
}
