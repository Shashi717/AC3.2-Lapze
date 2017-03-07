//
//  GoogleMapThumbView.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/7/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit

class GoogleMapThumbView: UIView {
    private let padding: Int = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpView(){
        self.addSubview(profileImageView)
        self.addSubview(nameLabel)
        self.addSubview(titleLabel)
        self.addSubview(descriptionLabel)
        
        self.backgroundColor = ColorPalette.orangeThemeColor
        
        self.frame.size = CGSize(width: 150, height: 150)
        self.layer.cornerRadius = 10
        
        self.profileImageView.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalToSuperview().offset(padding)
            view.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        self.nameLabel.snp.makeConstraints { (view) in
            view.top.equalTo(profileImageView.snp.bottom)
            view.centerX.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { (view) in
            view.top.equalTo(nameLabel.snp.bottom).offset(padding)
            view.centerX.equalToSuperview()
        }
        
        self.descriptionLabel.snp.makeConstraints { (view) in
            view.top.equalTo(titleLabel.snp.bottom).offset(padding)
            view.leading.equalToSuperview().offset(padding)
            view.trailing.equalToSuperview().inset(padding)
        }
    }
    
    let profileImageView: UIImageView = {
        let imageview: UIImageView = UIImageView()
        imageview.image = UIImage(named: "010-man")
        imageview.contentMode = .scaleAspectFit
        imageview.layer.cornerRadius = 15
        return imageview
    }()
    
    var nameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .white
        label.text = "Thunder Cat"
        return label
    }()
    
    var titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .white
        label.text = "Speed Champ"
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.text = "Some random data"
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
}
