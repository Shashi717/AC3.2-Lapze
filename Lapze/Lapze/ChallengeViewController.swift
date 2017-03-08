//
//  ChallengeViewController.swift
//  Lapze
//
//  Created by Ilmira Estil on 3/8/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit


class ChallengeViewController: EventsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.hidesBackButton = true
        self.eventSegmentedControl.isHidden = true
        self.addButton.isHidden = true
        
        
        setupViewChallenge()
        
//        while challengeOn {
//            self.distanceLabel.text = String(distance)
//        }
        
    }
    //MARK: - Utilities
    
    func saveChallenge() {
        print("save challenge to fb")
        
        //save to firebase
        
        //go back to challenge home page
    }
    
    func endActivity() {
        print("end activity")
    }

    //MARK: - setup
    func setupViewChallenge() {
        self.view.addSubview(titleBar)
        self.view.addSubview(statusButton)
        self.titleBar.addSubview(distanceLabel)
        
        titleBar.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.width.equalToSuperview()
            view.height.equalTo(50)
        }
        
        statusButton.snp.makeConstraints { (view) in
            view.width.equalToSuperview()
            view.height.equalTo(50)
            view.bottom.equalToSuperview()
        }
        
        distanceLabel.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.width.equalToSuperview()
            view.height.equalTo(40)
        }
        
        
    }
    
    //MARK: - View init
    internal lazy var titleBar: UIView! = {
        let view = UIView()
        view.backgroundColor = ColorPalette.orangeThemeColor
        return view
    }()
    
    internal lazy var statusButton: UIButton = {
        let button = UIButton()
        button.setTitle("End", for: .normal)
        button.addTarget(self, action: #selector(self.endActivity), for: .touchUpInside)
        button.backgroundColor = ColorPalette.orangeThemeColor
        return button
    }()
    
    internal lazy var timeLabel: UILabel! = {
        let label = UILabel()
        label.text = "time here"
        return label
    }()
    
    internal lazy var distanceLabel: UILabel! = {
        let label = UILabel()
        label.text = "distance here"
        return label
    }()

}
