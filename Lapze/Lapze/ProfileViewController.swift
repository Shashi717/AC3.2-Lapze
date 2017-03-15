//
//  ProfileViewController.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/3/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Firebase
import FirebaseAuth
import Charts

protocol ProfileDelegate {
    func getActivityData(_ challenges: [Challenge])
}

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ProfileDelegate {
    
    let segments = ["Create Event", "Create Challenge"]
    let profileSetting = ProfileSettingsLauncher()
    let badgeTitles = ["Newbie","First Event","First Challenge","Benchwarmer","Challenger","Warrior", "Olympian", "Baller", "Lapzer", "Something"]
    var userBadges = [String]()
    let cellId = "badges"
    var userProfileImage = "0"
    let uid = FIRAuth.auth()?.currentUser?.uid
    
    let userStore = UserStore()
    var challengeRef: FIRDatabaseReference!
    let databaseRef = FIRDatabase.database().reference()
    private let challengeStore = ChallengeStore()
    //var userChallenges: [Challenge] = []
    var delegate: ProfileDelegate?
   
    var userChallenges: [Challenge] = [] {
        didSet {
            print("changed from \(oldValue) to \(userChallenges)")
            self.badgesCollectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "My Profile"
        self.view.backgroundColor = .white
        setupViewHierarchy()
        configureConstraints()
        loadUser()
        
        //test
        getUserChallenges()
        //setupDataChart(dataPoints: months, values: unitsSold)
    }
    
    func getUserChallenges() {
        challengeStore.getAllUserChallenges(userId: uid!) { (challenges) in
            self.userChallenges = challenges
            self.userRankLabel.text = "\(self.userChallenges.count)"
            
            //piechart data
            var activityDataDict = [String: Double]()
            for challenge in challenges {
                activityDataDict[challenge.type] = activityDataDict[challenge.type] ?? 1
            }
            self.setChart(userData: activityDataDict)
            self.getActivityData(challenges)
        }
    }
    
    //Test: set userchallenge data to implement badge count etc.
    func getActivityData(_ challenges: [Challenge]) {
        self.userChallenges = challenges
        for i in 0..<self.userChallenges.count {
            let values = ["\(i)": "\(self.badgeTitles[i])"]
            self.userStore.updateUserData(id: uid!, values: values, child: "badges")
        }
    }

    func loadUser() {
        guard let userId = uid else { return }
        userStore.getUser(id: userId) { (user) in
            self.usernameLabel.text = "\(user.name)"
            self.profileImageView.image = UIImage(named: "\(user.profilePic)")
            
            self.userBadges = user.badges //access to global var
        }
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
    }
    
    //MARK: - Collection data flow
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userChallenges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BadgesCollectionViewCell
        
        cell.badgeImageView.image = UIImage(named: "\(badgeTitles[indexPath.row])")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print(indexPath.row)
        
    }
    
    //MARK: - pie data
    func setChart(userData: [String: Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for (key, value) in userData {
            let dataEntry = PieChartDataEntry(value: Double(value), label: key, data: key as AnyObject)
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: nil)
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChart.data = pieChartData
        
        var colors: [UIColor] = []
        
        for _ in 0..<userData.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        pieChartDataSet.colors = colors
        
        self.pieChart.legend.enabled =  false
        self.pieChart.chartDescription?.text = ""
        self.pieChart.usePercentValuesEnabled = true
        self.pieChart.sizeToFit()
        
    }
    
    //test
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
    let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0]
    func setupDataChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            
            let dataEntry = BarChartDataEntry(x: Double(i), yValues: [values[i]])
            
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Units Sold")
        
        let chartData = BarChartData(dataSet: chartDataSet)
        horiBarChart.data = chartData
        horiBarChart.chartDescription?.text = ""
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
        self.view.addSubview(pieChart)
        self.view.addSubview(userRankLabel)
        
        //self.view.addSubview(barStatusContainer)
        //self.barStatusContainer.addSubview(horiBarChart)
        self.view.addSubview(activitiesLabel)
    
        
    }
    
    func configureConstraints() {
        topContainerView.snp.makeConstraints { (view) in
            view.width.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.4)
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
            view.top.equalTo(badgesCollectionView.snp.bottom)
            view.left.equalToSuperview().offset(8.0)
            view.height.equalTo(20)
        }
//        challengesLabel.snp.makeConstraints { (view) in
//            view.top.equalTo(activitiesLabel.snp.bottom).offset(16.0)
//            view.left.equalToSuperview().offset(8.0)
//            view.right.equalToSuperview().inset(8.0)
//            view.height.equalTo(50.0)
////        }
        
        pieChart.snp.makeConstraints { (view) in
            view.top.equalTo(badgesCollectionView.snp.bottom).offset(8)
            view.bottom.equalToSuperview()
            view.width.equalToSuperview().multipliedBy(0.6)
            view.centerX.equalToSuperview()
        }
        
//        barStatusContainer.snp.makeConstraints { (view) in
//            view.leading.equalToSuperview()
//            view.width.equalToSuperview().multipliedBy(0.5)
//            view.top.equalTo(badgesCollectionView.snp.bottom).offset(8.0)
//            view.bottom.equalToSuperview()
//        }
        
//        horiBarChart.snp.makeConstraints { (view) in
//            view.leading.trailing.equalToSuperview()
//            view.top.bottom.equalToSuperview()
//            //view.width.equalToSuperview().multipliedBy(0.75)
//        }
    }

    

    //MARK: - Views
    internal var horiBarChart: HorizontalBarChartView = {
        let view = HorizontalBarChartView()
        return view
    }()
    
    internal var barStatusContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    internal var barStatusOne: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()
    //test^^
    
    internal var pieChart: PieChartView = {
        let view = PieChartView()
        return view
    }()
   
    
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
        label.text = "Top Activities"
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
