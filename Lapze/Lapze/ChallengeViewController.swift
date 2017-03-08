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
    }
    

    
    //MARK: - setup
    func setupViewChallenge() {
        self.view.addSubview(statusBar)
        
        statusBar.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.width.equalToSuperview()
            view.height.equalTo(50)
        }
    }
    
    //MARK: - View init
    internal lazy var statusBar: UIView! = {
        let view = UIView()
        view.backgroundColor = ColorPalette.orangeThemeColor
        return view
    }()

}
