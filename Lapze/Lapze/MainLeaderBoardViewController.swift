//
//  MainLeaderBoardViewController.swift
//  Lapze
//
//  Created by Ilmira Estil on 3/13/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit


class MainBadgesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let cellId = "badgeCell"
    let badgeTitles = ["Newbie","First Event","First Challenge","Benchwarmer","Challenger","Warrior", "Olympian", "Baller", "Lapzer", "Something"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setup()
    }

    func setup() {
        mainBadgesCollectionView.delegate = self
        mainBadgesCollectionView.dataSource = self
        mainBadgesCollectionView.register(BadgesCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        self.view.addSubview(topContainerView)
        self.topContainerView.addSubview(titleLabel)
        self.view.addSubview(mainBadgesCollectionView)
        
        topContainerView.snp.makeConstraints { (view) in
            view.width.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.25)
            view.top.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
            view.height.equalTo(40)
        }
        
        mainBadgesCollectionView.snp.makeConstraints { (view) in
            view.width.equalToSuperview()
            view.top.equalTo(topContainerView.snp.bottom)
            view.bottom.equalToSuperview()
        }
    }
    
    //MARK: - Collection data flow
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badgeTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BadgesCollectionViewCell
        
        cell.badgeImageView.image = UIImage(named: "\(badgeTitles[indexPath.row])")
        cell.badgeLabel.text = "\(badgeTitles[indexPath.row])"
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print(indexPath.row)
    }
    
    func showLeaderboard() {
        print("show leaderBoard")
        self.navigationController?.pushViewController(LeaderBoardViewController(), animated: true)
    }
    

  //MARK: - views
    
    internal var topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        return view
    }()
    
    internal var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Badge Collection"
        label.textAlignment = .center
        return label
    }()
    
    internal var mainBadgesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        //layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .purple
        return cv
    }()
    
    
}