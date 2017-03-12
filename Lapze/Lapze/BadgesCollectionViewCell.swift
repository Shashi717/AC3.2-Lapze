//
//  BadgesCollectionViewCell.swift
//  Lapze
//
//  Created by Ilmira Estil on 3/12/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class BadgesCollectionViewCell: BaseCell {
    override func setupViews() {
        super.setupViews()
        backgroundColor = .clear
        
        addSubview(badgeImageView)
        badgeImageView.snp.makeConstraints { (view) in
            view.size.equalToSuperview()
        }
    }
    
    
    //MARK: - inits
    internal var badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "004-boy")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
}
