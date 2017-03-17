//
//  LeaderBoardViewController.swift
//  Lapze
//
//  Created by Ilmira Estil on 3/13/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import Firebase

class LeaderBoardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let cellId = "leaderCell"
     let userStore = UserStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.navigationItem.title = "Leaderboard"
        setup()
        loadUsers()
    }
    
    var users: [User] = [] {
        didSet {
            print("changed from \(oldValue) to \(users.count)")
            self.leaderBoardCollectionView.reloadData()
        }
    }

    //MARK: - Utilities
    func setup() {
        self.view.addSubview(topContainerView)
        self.view.addSubview(leaderBoardCollectionView)
        
        leaderBoardCollectionView.delegate = self
        leaderBoardCollectionView.dataSource = self
        leaderBoardCollectionView.register(LeaderBoardCollectionCell.self, forCellWithReuseIdentifier: cellId)
        
        topContainerView.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.width.equalToSuperview()
            view.height.equalTo(100)
        }
        
        leaderBoardCollectionView.snp.makeConstraints { (view) in
            view.width.equalToSuperview()
            view.height.equalTo(300)
            //view.top.equalTo(showBadgesButton.snp.bottom)
            view.bottom.equalToSuperview()
        }
    }
    
    func loadUsers() {
        userStore.getAllUsers { (users) in
            self.users = users
            dump("users \(users)")
        }
    }
    
    func showBadges() {
        print("show stickers")
        self.navigationController?.pushViewController(MainBadgesViewController(), animated: true)
    }
    
    //MARK: - Collection data flow
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LeaderBoardCollectionCell
        
        cell.rankNumLabel.text = "\(Int(indexPath.row) + 1)"
        cell.nameLabel.text = "\(self.users[indexPath.row].name)"
        cell.profileImageView.image = UIImage(named: "\(self.users[indexPath.row].profilePic)")
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: leaderBoardCollectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    

   //MARK: - views
    internal var leaderBoardCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .purple
        return cv
    }()
    
    internal let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        return view
    }()

}
