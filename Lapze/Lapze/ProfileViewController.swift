//
//  ProfileViewController.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/3/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let segments = ["Create Event", "Create Challenge"]
    let profileSetting = ProfileSettingsLauncher()
    let badges = ["1", "2", "3", "4", "5"]
    let cellId = "badges"
    var userProfileImage = "1"
    let uid = FIRAuth.auth()?.currentUser?.uid
    private let userStore = UserStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "My Profile"
        self.view.backgroundColor = .white
        setupViewHierarchy()
        configureConstraints()
        loadUser()
        
        
    }
    
    func loadUser() {
        userStore.getUser(id: uid!) { (user) in
            self.usernameLabel.text = "\(user.name)"
        }
        profileImageView.image = UIImage(named: "\(userProfileImage)")
        userRankLabel.text = "Rank: Master Rider"
        activitiesLabel.text = "Activities: Biking, Running"
        challengesLabel.text = "Challenges: Running"
    }
    
    func logoutButtonTapped(sender: UIBarButtonItem) {
        do {
            try FIRAuth.auth()?.signOut()
            let alertController = showAlert(title: "Logout Successful!", message: "You have logged out successfully. Please log back in if you want to enjoy the features.", useDefaultAction: true)
            self.present(alertController, animated: true, completion: nil)
        }
        catch
        {
            let alertController = showAlert(title: "Logout Unsuccessul!", message: "Error occured. Please try again.", useDefaultAction: true)
            self.present(alertController, animated: true, completion: nil)

        }
    }
    
    func pickAvatar() {
        print("picking pic")
        profileSetting.showAvatars()
        DispatchQueue.main.async {
            let image = self.profileSetting.chosenProfileImage
            self.profileImageView.image = UIImage(named: "\(image)")
        }
        
    }
    
    //MARK: - Collection data flow
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BadgesCollectionViewCell
        
        cell.badgeImageView.image = UIImage(named: "\(badges[indexPath.row])")
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print(indexPath.row)
        
    }
    
    //MARK: - setup
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        
        badgesCollectionView.delegate = self
        badgesCollectionView.dataSource = self
        badgesCollectionView.register(BadgesCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        navigationItem.rightBarButtonItem = logoutButton
        self.view.addSubview(topContainerView)
        self.topContainerView.addSubview(profileImageView)
        self.topContainerView.addSubview(usernameLabel)
        self.view.addSubview(badgesCollectionView)
        self.view.addSubview(userRankLabel)
        self.view.addSubview(activitiesLabel)
    }
    
    func configureConstraints() {
        topContainerView.snp.makeConstraints { (view) in
            view.width.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.5)
            view.top.equalToSuperview()
        }
        
        badgesCollectionView.snp.makeConstraints { (view) in
            view.width.equalToSuperview()
            view.height.equalTo(60)
            view.top.equalTo(topContainerView.snp.bottom)
        }
        
        profileImageView.snp.makeConstraints { (view) in
            view.width.height.equalTo(150.0)
            view.top.equalToSuperview().inset(8.0)
            view.centerX.equalToSuperview()
        }
        usernameLabel.snp.makeConstraints { (view) in
            view.top.equalTo(profileImageView.snp.bottom).offset(8.0)
            view.centerX.equalToSuperview()
            view.left.equalToSuperview().offset(8.0)
            view.right.equalToSuperview().inset(8.0)
            view.height.equalTo(20.0)
        }
        userRankLabel.snp.makeConstraints { (view) in
            view.top.equalTo(usernameLabel.snp.bottom).offset(8.0)
            view.left.equalToSuperview().offset(8.0)
            view.right.equalToSuperview().inset(8.0)
            view.height.equalTo(20.0)
        }
        activitiesLabel.snp.makeConstraints { (view) in
            view.top.equalTo(userRankLabel.snp.bottom).offset(16.0)
            view.left.equalToSuperview().offset(8.0)
            view.right.equalToSuperview().inset(8.0)
            view.height.equalTo(50.0)
        }
//        challengesLabel.snp.makeConstraints { (view) in
//            view.top.equalTo(activitiesLabel.snp.bottom).offset(16.0)
//            view.left.equalToSuperview().offset(8.0)
//            view.right.equalToSuperview().inset(8.0)
//            view.height.equalTo(50.0)
////        }
    }
    

    //MARK: - Views
    internal var topContainerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.backgroundColor = ColorPalette.darkBlue
        return view
    }()
    
    internal var badgesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .purple
        return cv
    }()
    
    internal lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 75.0
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = ColorPalette.purpleThemeColor.cgColor
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickAvatar))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()

    internal lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    internal lazy var userRankLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    internal lazy var activitiesLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    internal lazy var challengesLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    internal lazy var logoutButton: UIBarButtonItem = {
        var barButton = UIBarButtonItem()
        barButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logoutButtonTapped(sender:)))
        return barButton
    }()
    
 
   
}
