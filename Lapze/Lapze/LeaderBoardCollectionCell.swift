//
//  LeaderBoardCollectionCell.swift
//  Lapze
//
//  Created by Ilmira Estil on 3/13/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import UIKit

class LeaderBoardCollectionCell: BaseCell {
    override func setupViews() {
        super.setupViews()
        backgroundColor = .blue
        
        addSubview(profileImageView)
        addSubview(leaderboardLabel)
        
        profileImageView.snp.makeConstraints { (view) in
            view.height.equalToSuperview()
            view.width.equalTo(50)
            view.leading.equalToSuperview()
        }
        
        leaderboardLabel.snp.makeConstraints { (view) in
            view.leading.equalTo(profileImageView.snp.trailing).offset(8)
            view.width.equalToSuperview()
            view.height.equalTo(20)
        }
    }
    
    
    //MARK: - inits
    internal var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "question")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    internal var leaderboardLabel: UILabel = {
        let label = UILabel()
        label.text = "User data here and some action, time"
        return label
    }()
}
