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
        addSubview(nameLabel)
        addSubview(rankNumLabel)
        
        profileImageView.snp.makeConstraints { (view) in
            view.height.equalToSuperview()
            view.width.equalTo(50)
            view.leading.equalToSuperview().offset(20)
        }
        
        nameLabel.snp.makeConstraints { (view) in
            view.leading.equalTo(profileImageView.snp.trailing).offset(8)
            view.width.equalToSuperview()
            view.height.equalTo(20)
        }
        
        rankNumLabel.snp.makeConstraints { (view) in
            view.leading.equalToSuperview().offset(5)
            view.trailing.equalTo(profileImageView.snp.leading).offset(8)
            view.height.equalTo(profileImageView.snp.height)
        }
    }
    
    //MARK: - inits
    internal var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "question")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 50
        return imageView
    }()
    
    internal var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "User data here and some action, time"
        return label
    }()
    
    internal var rankNumLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        label.font = UIFont(name: "Avenir Next", size: 22)
        return label
    }()
}
