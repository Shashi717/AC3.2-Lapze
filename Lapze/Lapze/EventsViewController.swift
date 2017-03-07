//
//  EventsViewController.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/3/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit
import UserNotifications
import GoogleMaps
import CoreLocation
import FirebaseDatabase
import FirebaseAuth

public enum Event: String {
    case currentEvents = "Events"
    case challenges = "Challenges"
}

class EventsViewController: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate {
    private var userLocation: CLLocation?{
        didSet{
            findUser()
            addLocationtoFireBase(location: userLocation!)
        }
    }
    
    let events: [Event.RawValue] = [Event.currentEvents.rawValue, Event.challenges.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Current Events"
        
        setupViewHierarchy()
        configureConstraints()
        //createPopup()
        //createThumbView(userName: "noo")
        
        
        //initial view of events
        self.eventSegmentedControl.selectedSegmentIndex = 0
        
        
        //tap gesture
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        view.addGestureRecognizer(tap)
        GoogleMapManager.shared.manage(map: self.googleMapView)
        googleMapView.delegate = self
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        FirebaseObserver.manager.stopObserving()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FirebaseObserver.manager.startObserving(node: .location)
    }
    
    //MARK: - Utilities
    func segementedControlValueChanged(sender: UISegmentedControl) {
        let segment = eventSegmentedControl.selectedSegmentIndex
        switch segment {
        case 0:
            print("\(events[0])")
            //thumbButton.setTitle("Join", for: .normal)
            self.navigationItem.title = "Current Events"
            //real time public user event data
            
        case 1:
            print("\(events[1])")
            //thumbButton.setTitle("Challenge", for: .normal)
            self.navigationItem.title = "Challenge!"
            //saved event data - start locations, and stats
            
        default:
            print("none")
        }
    }
    
    func fillPopupForCreateEvent() {
        popupContainerView.backgroundColor = ColorPalette.purpleThemeColor
        profileImageView.layer.borderColor = ColorPalette.orangeThemeColor.cgColor
        
        thumbStatContainerView.backgroundColor = ColorPalette.purpleThemeColor
        thumbProfileImageView.layer.borderColor = ColorPalette.orangeThemeColor.cgColor
    }
    
    func fillPopupForChallenge() {
        popupContainerView.backgroundColor = ColorPalette.orangeThemeColor
        profileImageView.layer.borderColor = ColorPalette.purpleThemeColor.cgColor
        
        thumbStatContainerView.backgroundColor = ColorPalette.orangeThemeColor
        thumbProfileImageView.layer.borderColor = ColorPalette.purpleThemeColor.cgColor
    }
    
    func fillMockupDataForThumbView() {
        thumbUserNameLabel.text = "CoolGuy123"
        thumbChallengeDescriptionLabel.text = "Bike Champ"
        thumbChallengeStatsLabel.text = "Ran 10 mile in 1 hr"
    }
    
    //MARK: - Setup
    func createThumbView(userName: String) {
        self.view.addSubview(thumbStatContainerView)
        self.thumbStatContainerView.addSubview(thumbButton)
        self.thumbStatContainerView.addSubview(thumbProfileImageView)
        self.thumbStatContainerView.addSubview(thumbUserNameLabel)
        self.thumbStatContainerView.addSubview(thumbChallengeDescriptionLabel)
        self.thumbStatContainerView.addSubview(thumbChallengeStatsLabel)
        
        
        thumbStatContainerView.snp.makeConstraints { (view) in
            view.height.equalTo(130.0)
            view.width.equalTo(180.0)
            
            //should be changed to the location of the pin
            view.centerX.centerY.equalToSuperview()
        }
        
        thumbButton.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(4.0)
            view.right.equalToSuperview().inset(4.0)
            view.width.height.equalTo(40.0)
        }
        thumbProfileImageView.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(4.0)
            view.height.width.equalTo(50.0)
            view.centerX.equalToSuperview()
        }
        thumbUserNameLabel.snp.makeConstraints { (view) in
            view.top.equalTo(thumbProfileImageView.snp.bottom).offset(4.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(15.0)
        }
        thumbChallengeStatsLabel.snp.makeConstraints { (view) in
            view.left.right.equalToSuperview()
            view.bottom.equalToSuperview().inset(2.0)
            view.height.equalTo(15.0)
        }
        thumbChallengeDescriptionLabel.snp.makeConstraints { (view) in
            view.left.right.equalToSuperview()
            view.top.equalTo(thumbUserNameLabel.snp.bottom)
            view.bottom.equalTo(thumbChallengeStatsLabel.snp.top)
        }
    }
    
    func createPopup() {
        self.thumbStatContainerView.addSubview(popupContainerView)
        self.popupContainerView.addSubview(profileImageView)
        self.popupContainerView.addSubview(challengeStatsLabel)
        self.popupContainerView.addSubview(challengeDescriptionLabel)
        
        popupContainerView.snp.makeConstraints { (view) in
            view.centerX.centerY.equalToSuperview()
            view.height.equalTo(200.0)
            view.width.equalTo(250.0)
        }
        profileImageView.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(16.0)
            view.height.width.equalTo(70.0)
            view.centerX.equalToSuperview()
        }
        challengeStatsLabel.snp.makeConstraints { (view) in
            view.left.right.bottom.equalToSuperview()
            view.height.equalTo(10.0)
        }
        challengeDescriptionLabel.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.width.equalTo(160.0)
            view.top.equalTo(profileImageView.snp.bottom).offset(8.0)
            view.bottom.equalTo(challengeStatsLabel.snp.top).inset(8.0)
        }
    }
    
    func thumbButtonTapped(sender: UIButton) {
        let selectedSegmentIndex = eventSegmentedControl.selectedSegmentIndex
        
        switch selectedSegmentIndex {
        case 0:
            notificationEvent()
            joinedCurrentEvent()
            
        case 1:
            print("Challenge Event")
        default:
            break
        }
    }
    
    func addButtonTapped(sender: UIButton) {
        print("add button tapped")
        let createEventVc = CreateEventViewController()
        self.show(createEventVc, sender: self)
    }
    
    func joinedCurrentEvent() {
        print("Join event")
        //this should change mapview to specific event
        //dismissPopup()
    }
    
    func notificationEvent() {
        let content = UNMutableNotificationContent()
        content.title = "Join Event"
        content.subtitle = "Phoebe's event"
        content.body = "You are joining Phoebe's yoga session"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "event", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func testButtonTapped(sender: UIButton) {
        print("test button tapped")
       //eventPopup()
        let popVc = PopupViewController()
        popVc.modalTransitionStyle = .crossDissolve
        popVc.modalPresentationStyle = .overCurrentContext
        self.present(popVc, animated: true, completion: nil)
        
    }
    
    func eventPopup() {
        print("want to join this event?")
        //popup box
        thumbButton.setImage(UIImage(named: "Join3"), for: .normal)
        fillPopupForCreateEvent()
        fillMockupDataForThumbView()
        self.thumbStatContainerView.isHidden = false
        self.view.addSubview(blurView)
    }
    
    func dismissPopup() {
        print("tap gesture")
        self.thumbStatContainerView.isHidden = true
        self.blurView.removeFromSuperview()
    }
    
    
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        self.view.addSubview(googleMapView)
        self.view.addSubview(eventSegmentedControl)
        self.googleMapView.addSubview(locateMeButton)
        
        let item1 = UIBarButtonItem(customView: addButton)
        self.navigationItem.setLeftBarButton(item1, animated: true)
        
        let item2 = UIBarButtonItem(customView: testButton)
        self.navigationItem.setRightBarButton(item2, animated: true)
        
        locationManager.delegate = self
    }
    
    func configureConstraints() {
        eventSegmentedControl.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(25.0)
            view.width.equalTo(160.0)
            view.height.equalTo(40.0)
            view.centerX.equalToSuperview()
        }
        
        googleMapView.snp.makeConstraints { (view) in
            view.top.bottom.leading.trailing.equalToSuperview()
        }
        
        locateMeButton.snp.makeConstraints { (view) in
            view.trailing.centerY.equalToSuperview()
        }
        
    }
    
    //MARK: Location Utilities
    private func addUserToMap(){
        
    }
    
    func addLocationtoFireBase(location: CLLocation){
        let childRef = FirebaseObserver.manager.dataBaseRefence.child("Location").child((FIRAuth.auth()?.currentUser?.uid)!)
        childRef.updateChildValues(["lat": location.coordinate.latitude,"long":location.coordinate.longitude]) { (error, ref) in
            if error != nil{
                print(error?.localizedDescription)
                
            }else{
                print("Success adding location")
            }
        }
    }
    
    func findUser(){
        if let location = userLocation{
            let clocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            googleMapView.animate(toLocation: clocation)
            googleMapView.animate(toZoom: 15)
        }
    }
    //MARK: Location manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let validLocation: CLLocation = locations.last else { return }
        self.userLocation = validLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status{
        case .authorizedAlways, .authorizedWhenInUse:
            print("All good")
            //manager.startUpdatingLocation()
            manager.startMonitoringSignificantLocationChanges()
            
        case .denied, .restricted:
            print("NOPE")
            locationManager.requestAlwaysAuthorization()
            
        case .notDetermined:
            print("IDK")
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    //MARK: Googlemaps Delegate methods
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let view: GoogleMapThumbView = GoogleMapThumbView()
        view.profileImageView.image = marker.icon
        return view
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("show delegate profile")
    }
    
    
    //MARK: - Views
    private let googleMapView: GMSMapView = {
        let mapview: GMSMapView = GMSMapView()
        mapview.translatesAutoresizingMaskIntoConstraints = false
        mapview.mapType = .normal
        mapview.isBuildingsEnabled = false
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapview.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        return mapview
    }()
    
    private let locationManager: CLLocationManager = {
        let locMan: CLLocationManager = CLLocationManager()
        locMan.desiredAccuracy = 100.0
        locMan.distanceFilter = 50.0
        return locMan
    }()
    
    private let locateMeButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("Me", for: .normal)
        button.addTarget(self, action: #selector(findUser), for: .touchUpInside)
        button.backgroundColor = ColorPalette.logoGreenColor
        return button
    }()
    
    internal lazy var eventSegmentedControl: UISegmentedControl! = {
        var segmentedControl = UISegmentedControl()
        segmentedControl = UISegmentedControl(items: self.events)
        let font = UIFont.systemFont(ofSize: 14)
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        segmentedControl.tintColor = .white
        segmentedControl.backgroundColor = ColorPalette.purpleThemeColor
        segmentedControl.addTarget(self, action: #selector(segementedControlValueChanged(sender:)), for: .valueChanged)
        return segmentedControl
    }()
    internal lazy var popupContainerView: UIView! = {
        let view = UIView()
        view.layer.cornerRadius = 15.0
        view.layer.masksToBounds = false
        return view
    }()
    internal lazy var profileImageView: UIImageView! = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 35.0
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = false
        return imageView
    }()
    internal lazy var challengeDescriptionLabel: UILabel! = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    internal lazy var challengeStatsLabel: UILabel! = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    internal lazy var thumbStatContainerView: UIView! = {
        let view = UIView()
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = false
        return view
    }()
    internal lazy var thumbProfileImageView: UIImageView! = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25.0
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = false
        return imageView
    }()
    internal lazy var thumbUserNameLabel: UILabel! = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    internal lazy var thumbChallengeDescriptionLabel: UILabel! = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    internal lazy var thumbChallengeStatsLabel: UILabel! = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    internal lazy var thumbButton: UIButton! = {
        let button = UIButton()
        // button.titleLabel!.font =  UIFont(name: "System - System", size: 5)
        // button.backgroundColor = ColorPalette.logoGreenColor
        //        button.layer.cornerRadius = 10.0
        //        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(thumbButtonTapped(sender:)), for: .touchUpInside)
        return button
    }()
    internal lazy var addButton: UIButton! = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Add"), for: .normal)
        button.addTarget(self, action: #selector(addButtonTapped(sender:)), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return button
    }()
    internal lazy var testButton: UIButton! = {
        let button = UIButton()
        button.setTitle("test", for: .normal)
        button.addTarget(self, action: #selector(testButtonTapped(sender:)), for: .touchUpInside)
        button.frame = CGRect(x:0, y:0, width: 30, height: 30)
        return button
    }()
    
    internal lazy var blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurView
    }()
}

