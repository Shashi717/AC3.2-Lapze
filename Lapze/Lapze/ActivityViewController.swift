//
//  ActivityViewController.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/10/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit

import FirebaseDatabase

class ActivityViewController: UIViewController,EventViewControllerDelegate,ChallengeDelegate,JoinActivityDelegate {
    private let mapViewController: MapViewController = MapViewController()
    private let topInfoView: TopActivityInfoView = TopActivityInfoView()
    private let bottomScrollInfoView: BottomActivityInfoScrollView = BottomActivityInfoScrollView()
    private var showInfoWindow: Bool = false
    private var timer: Timer = Timer()
    private var activityTime: Double = 0.0
    private let timeInterval:TimeInterval = 1
    private let timerEnd:TimeInterval = 0.0
    private var counter = 0
    private let challengeStore: ChallengeStore = ChallengeStore()

    
    fileprivate var viewControllerState: MapViewControllerState = .events{
        didSet{
            updateInterface()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateInterface()
        setUpController()
    }
    
    private func setUpController(){
        addMapViewController()
        setUpViews()
    }
    
    private func addMapViewController(){
        //Add Child view controller
        addChildViewController(mapViewController)
        
        //Add child view as Subview
        view.addSubview(mapViewController.view)
        
        //Configure child view
        mapViewController.view.frame = view.bounds
        
        //Notify child view controller
        mapViewController.didMove(toParentViewController: self)
        
        //Default map state
        mapViewController.updateMapState(state: .events)
    }
    //MARK:- Map Utilties
    @objc private func changeMapState(sender: UISegmentedControl){
        guard let activity = MapViewControllerState(rawValue: sender.selectedSegmentIndex) else { return }
        
        viewControllerState = activity
        mapViewController.updateMapState(state: activity)
    }
    
    //MARK:- User Interface Utilities
    private func updateInterface(){
        switch viewControllerState{
        case .events:
            addButton.backgroundColor = ColorPalette.purpleThemeColor
            topInfoView.backgroundColor = ColorPalette.greenThemeColor
            bottomScrollInfoView.actionButton.backgroundColor = ColorPalette.greenThemeColor
            navigationItem.title = "Current Events"
        case .challenges:
            addButton.backgroundColor = ColorPalette.orangeThemeColor
            topInfoView.backgroundColor = ColorPalette.orangeThemeColor
            bottomScrollInfoView.actionButton.backgroundColor = ColorPalette.orangeThemeColor
            navigationItem.title = "Challenge!"
        }
    }
    
    @objc private func createActivityHandle(){
        switch viewControllerState{
        case .challenges:
            let challengeVc: CreateChallengeViewController = CreateChallengeViewController()
            navigationController?.pushViewController(challengeVc, animated: true)
            challengeVc.delegate = self
        case .events:
            let eventVc: CreateEventViewController = CreateEventViewController()
            navigationController?.pushViewController(eventVc, animated: true)
            eventVc.delegate = self
        }
    }
    
    @objc private func animateInfoWindow(){
        let animator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 0.7)
        showInfoWindow = !showInfoWindow
        switch showInfoWindow{
        case false:
            animator.addAnimations({
                self.topInfoView.transform = CGAffineTransform.identity
                self.bottomScrollInfoView.transform = CGAffineTransform.identity
                self.mapViewController.locateMeButton.transform = CGAffineTransform.identity
            }, delayFactor: 0.5)
            
        case true:
            animator.addAnimations ({
                self.bottomScrollInfoView.transform = CGAffineTransform(translationX: 0, y: -60)
                self.topInfoView.transform = CGAffineTransform(translationX: 0, y: 60)
                self.mapViewController.locateMeButton.transform = CGAffineTransform(translationX: 0, y: -60)
                
            }, delayFactor: 0.5)
            
            animator.addCompletion({ (position) in
                if position == .end{
                    self.animateBottomScrollInfoView()
                }
            })
        }
        animator.startAnimation()
    }
    
    private func animateBottomScrollInfoView(){
        let animator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 1.5, dampingRatio: 0.9)
        
        animator.addAnimations{
            self.bottomScrollInfoView.contentOffset = CGPoint(x:(self.bottomScrollInfoView.actionButton.frame.width) * 0.9,y:0)
        }
        
        animator.addAnimations({
            self.bottomScrollInfoView.contentOffset = CGPoint(x: 0, y: 0)
        }, delayFactor: 0.7)
        
        animator.startAnimation()
    }
    
    //MARK:- Views
    private func setUpViews(){
        edgesForExtendedLayout = []
        self.view.addSubview(activitySegmentedControl)
        self.view.addSubview(addButton)
        self.view.addSubview(topInfoView)
        self.view.addSubview(bottomScrollInfoView)
        
        addButton.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.width.height.equalTo(50)
            view.bottom.equalToSuperview().inset(10)
        }
        
        topInfoView.snp.makeConstraints { (view) in
            view.height.equalToSuperview().multipliedBy(0.11)
            view.trailing.leading.equalToSuperview()
            view.bottom.equalTo(self.view.snp.top)
        }
        
        bottomScrollInfoView.snp.makeConstraints { (view) in
            view.height.equalToSuperview().multipliedBy(0.11)
            view.trailing.leading.equalToSuperview()
            view.top.equalTo(self.view.snp.bottom)
        }
        
        bottomScrollInfoView.container.snp.makeConstraints { (view) in
            view.height.equalTo(self.view.snp.height).multipliedBy(0.11)
            view.width.equalTo(self.view.snp.width).multipliedBy(2)
        }
        
        activitySegmentedControl.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(25.0)
            view.width.equalToSuperview().multipliedBy(0.85)
            view.height.equalTo(30.0)
            view.centerX.equalToSuperview()
        }
    }
    
    //MARK:- Event Delegate methods
    func startEvent(name: String){
        topInfoView.titleLabel.text = "Your \(name) session"
        bottomScrollInfoView.actionButton.setTitle("End Event", for: .normal)
        bottomScrollInfoView.actionButton.addTarget(self, action: #selector(endEvent), for: .touchUpInside)
        mapViewController.startActivity()
        startTimer()
        animateInfoWindow()
    }
    

    @objc private func endEvent() {

        mapViewController.endActivity()
        stopTimer()
        animateInfoWindow()
    }
    

    //MARK:- Challenge Delegate Methods
    func challengeCreated(_ challenge: Challenge) {
        challengeStore.add(challenge)
        
    }
    
    private func endChallenge(){
      
        
    }
    //MARK:- Join Challenge Delegate method
    func joinChallenge(user: String, challengeId: String) {
        challengeStore.getChallenge(id: challengeId) { (challenge) in
            self.topInfoView.titleLabel.text = challenge.name
        }
    }
    

    //MARK:- Timer Utilities
    private func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    private func stopTimer(){
        timer.invalidate()
        counter = 0
    }
    
    @objc private func tick(){
        counter += 1
        bottomScrollInfoView.infoView.timeLabel.text = timeString(TimeInterval(counter))

        bottomScrollInfoView.infoView.distanceLabel.text = String((mapViewController.distance/1609.34).roundTo(places: 2))

    }
    
    private func timeString(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    //MARK:- Views
    fileprivate lazy var activitySegmentedControl: UISegmentedControl = {
        var segmentedControl = UISegmentedControl(items: ["Events","Challenges"])
        let font = UIFont.systemFont(ofSize: 14)
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        segmentedControl.tintColor = .white
        segmentedControl.backgroundColor = ColorPalette.greenThemeColor
        segmentedControl.addTarget(self, action: #selector(changeMapState(sender:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private lazy var addButton: UIButton = {
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
        button.addTarget(self, action: #selector(createActivityHandle), for: .touchUpInside)
        return button
    }()
}
