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
        
        self.actionButton.isHidden = false
        
        
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

    //MARK: - setup
    func setupViewChallenge() {
        self.view.addSubview(statusBar)
        self.view.addSubview(actionButton)
        self.statusBar.addSubview(distanceLabel)
        
        statusBar.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.width.equalToSuperview()
            view.height.equalTo(50)
        }
        
        actionButton.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.bottom.equalToSuperview()
        }
        
        distanceLabel.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.width.equalToSuperview()
            view.height.equalTo(40)
        }
    }
    
    //MARK: - View init
    internal lazy var statusBar: UIView! = {
        let view = UIView()
        view.backgroundColor = ColorPalette.orangeThemeColor
        return view
    }()
    
    internal lazy var actionButton: UIButton! = {
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "add-1"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.snp.makeConstraints({ (view) in
            view.size.equalTo(CGSize(width: 30, height: 30))
        })
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = CGSize(width: 1, height: 5)
        button.layer.shadowRadius = 2
        button.backgroundColor = ColorPalette.purpleThemeColor
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(saveChallenge), for: .touchUpInside)
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
