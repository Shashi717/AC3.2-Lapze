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

private enum State {
    case home
    case event
    case challenge
}

class EventsViewController:UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate,EventDelegate,ChallengeDelegate {
    
    private var userLocation: CLLocation?{
        didSet{
            //findUser()
            //addLocationtoFireBase(location: userLocation!)
            updateUserLocationMarker(location: userLocation!)
        }
    }
    
    private let events: [Event.RawValue] = [Event.currentEvents.rawValue, Event.challenges.rawValue]
    
    private var challengeFirebaseRef: FIRDatabaseReference?
    private let databaseRef = FIRDatabase.database().reference()
    private var challengeOn = false
    private var state: State = .home
    
    private var path: [Location] = []
    
    private var userCreatedEvent: Bool = false
    private var currentUser = FIRAuth.auth()?.currentUser
    private var timer = Timer()
    private var challengeTime: Double = 0.0
    private let timeInterval:TimeInterval = 1
    private let timerEnd:TimeInterval = 0.0
    private var counter = 0
    
    private var userLocationMarker: GMSMarker?
    private var previousLocation: CLLocation?
    private var showUserLocation: Bool = true
    private var distance: Double = 0.0
    private var allChallenges: [Challenge] = []
    private var eventOn = false
    
    private let challengeStore = ChallengeStore()
    private let userStore = UserStore()
    let pathObject = Path()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Open Events"
        setupViewHierarchy()
        configureConstraints()
        
        //initial view of events
        self.eventSegmentedControl.selectedSegmentIndex = 0
        
        GoogleMapManager.shared.manage(map: self.googleMapView)
        googleMapView.delegate = self
        
        // FirebaseObserver.manager.startObserving(node: .location)
        
        //Change Map view to reflect part session/challenge
        if challengeOn {
            print("you're in a challenge")
        } else {
            print("not in a challenge")
        }
        
        locationManager.delegate = self
        
        challengeStore.getAllChallenges { (challenges) in
            self.allChallenges = challenges
        }
        findUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationManager.requestAlwaysAuthorization()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        FirebaseObserver.manager.stopObserving()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FirebaseObserver.manager.startObserving(node: .event)
        if challengeOn {
            print("you're in a challenge")
        }
    }
    
    func markChallenges(_ challenges: [Challenge]) {
        
        for challenge in challenges {
            
            GoogleMapManager.shared.addMarker(id: challenge.id, lat: challenge.lat, long: challenge.long, imageName: challenge.type)
            
        }
        
    }
    
    
    //MARK: - Utilities
    deinit {
        print("View died")
    }
    
    func segementedControlValueChanged(sender: UISegmentedControl) {
        
        let segment = eventSegmentedControl.selectedSegmentIndex
        let popVc = PopupViewController()
        pathObject.removePolyline()
        switch segment {
        case 0:
            GoogleMapManager.shared.hideAllMarkers()
            
            print("\(events[0])")
            //thumbButton.setTitle("Join", for: .normal)
            self.navigationItem.title = "Current Events"
            self.addButton.backgroundColor = ColorPalette.purpleThemeColor
            topStatusView.backgroundColor = ColorPalette.purpleThemeColor
            bottomStatusView.backgroundColor = ColorPalette.greenThemeColor
            popVc.segment = 0
            
        case 1:
            print("\(events[1])")
            GoogleMapManager.shared.hideAllMarkers()
            //thumbButton.setTitle("Challenge", for: .normal)
            self.navigationItem.title = "Challenge"
            self.addButton.backgroundColor = ColorPalette.orangeThemeColor
            topStatusView.backgroundColor = ColorPalette.orangeThemeColor
            bottomStatusView.backgroundColor = ColorPalette.orangeThemeColor
            popVc.segment = 1
            self.markChallenges(allChallenges)
        default:
            print("none")
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
        let selectedSegmentIndex = eventSegmentedControl.selectedSegmentIndex
        
        switch selectedSegmentIndex {
        case 0:
            let createEventVc = CreateEventViewController()
            createEventVc.delegate = self
            self.show(createEventVc, sender: self)
            
        case 1:
            if challengeOn == true {
                let alertController = showAlert(title: "Create Challenge Unsuccessful", message: "You are already on a challenge! Please end the current challenge to create a new challenge.", useDefaultAction: true)
                self.present(alertController, animated: true, completion: nil)
            }
            else {
                let createEventVc = CreateChallengeViewController()
                createEventVc.delegate = self
                self.show(createEventVc, sender: self)
            }
        default:
            break
        }
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
    
    
    func dismissPopup() {
        print("tap gesture")
        //self.blurView.removeFromSuperview()
    }
    
    //activity view setup
    func setupChallengeView() {
        _ = [
            self.eventSegmentedControl,
            self.addButton,
            self.locateMeButton
            ].map({$0.isHidden = true})
        
        _ = [
            self.topStatusView,
            self.topStatusLabel,
            self.bottomStatusView,
            self.bottomStatus1Label,
            self.bottomStatus2Label,
            self.endButton
            ].map({$0.isHidden = false})
    }
    
    //MARK: Location Utilities
    
    private func addUserToMap(){
        
    }
    
    
    //MARK: - User Auth Utilities
    func checkForUserLogin(){
        if FIRAuth.auth()?.currentUser == nil{
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }else{
            FirebaseObserver.manager.startObserving(node: .location)
        }
    }
    
    func handleLogout(){
        present(LoginViewController(), animated: true, completion: nil)
    }
    
    //MARK: Location Utilities
    fileprivate func addLocationtoFireBase(location: CLLocation){
        let childRef = FirebaseObserver.manager.dataBaseRefence.child("Events").child((FIRAuth.auth()?.currentUser?.uid)!)
        childRef.updateChildValues(["lat": location.coordinate.latitude,"long":location.coordinate.longitude]) { (error, ref) in
            
            if error != nil{
                print(error!.localizedDescription)
                
            }else{
                print("Success adding location")
            }
        }
    }
    
    private func updateUserLocationMarker(location:CLLocation){
        let locationCordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        switch showUserLocation{
            
        case true:
            if userLocationMarker == nil{
                userLocationMarker = GMSMarker(position: locationCordinate)
                userLocationMarker?.iconView = UserLocationMarker()
                userLocationMarker?.map = googleMapView
            }else{
                userLocationMarker?.position = locationCordinate
            }
        case false:
            removeUserMarker()
        }
    }
    private func showUserMarker(){
        self.userLocationMarker?.map = googleMapView
    }
    
    private func removeUserMarker(){
        self.userLocationMarker?.map = nil
    }
    
    func findUser(){
        if let location = userLocation{
            let clocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            googleMapView.animate(toLocation: clocation)
            googleMapView.animate(toZoom: 15)
        }
    }
    
    //MARK: Event Utilities
    func startEvent(name: String) {
        let eventPopUp: PopupViewController = PopupViewController()
        eventPopUp.challengeDescriptionLabel.text = "You just created a\(name) event!"
        eventPopUp.challengeDescriptionLabel.font = UIFont.boldSystemFont(ofSize: 20)
        eventPopUp.modalTransitionStyle = .crossDissolve
        eventPopUp.modalPresentationStyle = .overCurrentContext
        self.eventOn = true
        present(eventPopUp, animated: true, completion: nil)
        removeUserMarker()
        addEventToFireBase(type:name,location: userLocation!)
        self.endButton.addTarget(self, action: #selector(endEvent), for: .touchUpInside)
    }
    
    fileprivate func addEventToFireBase(type: String,location: CLLocation){
        let childRef = FirebaseObserver.manager.dataBaseRefence.child("Event").child((FIRAuth.auth()?.currentUser?.uid)!)
        childRef.updateChildValues(["lat": location.coordinate.latitude,"long":location.coordinate.longitude]) { (error, ref) in
            
            if error != nil{
                print(error!.localizedDescription)
                
            }else{
                print("Success adding location")
            }
        }
    }
    
    private func updateEventLocation(location: CLLocation){
        let childRef = FirebaseObserver.manager.dataBaseRefence.child("Event").child((FIRAuth.auth()?.currentUser?.uid)!)
        childRef.updateChildValues(["lat": location.coordinate.latitude,"long":location.coordinate.longitude]) { (error, ref) in
            
            if error != nil{
                print(error!.localizedDescription)
                
            }else{
                print("Success adding location")
            }
        }
    }
    
    @objc private func endEvent(){
        let childRef = FirebaseObserver.manager.dataBaseRefence.child("Event").child((FIRAuth.auth()?.currentUser?.uid)!)
        childRef.removeValue()
        self.eventOn = false
        self.showUserMarker()
    }
    
    //MARK: Location manager Delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let validLocation: CLLocation = locations.last else { return }
        
        self.userLocation = validLocation
        
        let locationObject = Location(lat: validLocation.coordinate.latitude, long: validLocation.coordinate.longitude)
        
        if challengeOn == true {
            
            path.append(locationObject)
            //calculating distance
            let currentLocation = manager.location!
            print("Current Location: \(currentLocation)")
            
            
            if previousLocation != nil {
                let lastDistance = currentLocation.distance(from: previousLocation as CLLocation!)
                //distance in meters
                
                distance += lastDistance
            }
            
            previousLocation = currentLocation
            
            print("Previous Location: \(previousLocation)")
            print("Distance: \(distance)")
            
            //challenge view
            
            self.bottomStatus1Label.text = "\((distance/1609.34).roundTo(places: 2)) miles"
            
            
        }
        if eventOn{
            self.updateEventLocation(location: validLocation)
        }
        print("location change")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status{
        case .authorizedAlways, .authorizedWhenInUse:
            print("All good")
            manager.startUpdatingLocation()
            //manager.startMonitoringSignificantLocationChanges()
            
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
        
        let thumbView: GoogleMapThumbView = GoogleMapThumbView()
        marker.tracksInfoWindowChanges = true
        guard marker != userLocation else { return nil}
        
        let selectedSegmentIndex = eventSegmentedControl.selectedSegmentIndex
        
        switch selectedSegmentIndex {
        case 0:
            //event
            
            thumbView.backgroundColor = ColorPalette.purpleThemeColor
        case 1:
            //challengea
            thumbView.backgroundColor = ColorPalette.orangeThemeColor
            
            
            
            if let id = marker.title {
                challengeStore.getChallenge(id: id) { (challenge) in
                    self.userStore.getUser(id: challenge.champion, completion: { (user) in
                        thumbView.currentChampionNameLabel.text = ("Champion: \(user.name)")
                    })
                    thumbView.profileImageView.image = UIImage(named: challenge.type)
                    thumbView.titleLabel.text = challenge.name
                    thumbView.descriptionLabel.text = ("\(challenge.type), \(challenge.lastUpdated) ")
                }
            }
            
        default:
            break
        }
        return thumbView
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("show delegate profile")
        let popVc = PopupViewController()
        popVc.modalTransitionStyle = .crossDissolve
        popVc.modalPresentationStyle = .overCurrentContext
        
        let selectedSegmentIndex = eventSegmentedControl.selectedSegmentIndex
        
        switch selectedSegmentIndex {
        case 0:
            popVc.segment = 0
            self.present(popVc, animated: true, completion: nil)
        case 1:
            popVc.segment = 1
            if let id = marker.title {
                challengeStore.getChallenge(id: id) { (challenge) in
                    self.userStore.getUser(id: challenge.champion, completion: { (user) in
                        popVc.challengeDescriptionLabel.text = "\(user.name): Champion since \(challenge.lastUpdated) "
                        
                    })
                    popVc.challengeNameLabel.text = challenge.name
                    popVc.challengeStatsLabel.text = "\(challenge.type)"
                }
            }
            self.present(popVc, animated: true, completion: nil)
        default:
            break
        }
    }
    
    //MARK: Challenge Delegate methods
    func startChallenge(id: String, linkRef: FIRDatabaseReference) {
        
        self.challengeOn = true
        
        self.challengeFirebaseRef = linkRef
        self.challengeTime = 0
        self.state = .challenge
        updateViews(.challenge)
        
        //delete setupChallenge
        
        self.endButton.addTarget(self, action: #selector(self.endChallenge), for: .touchUpInside)
        
        //timer
        
        self.timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
        
        print("challenge id: \(id)")
        let chalStore = ChallengeStore()
        chalStore.getChallenge(id: id) { (challenge) in
            print("challenge id: \(id), name: \(challenge.name)")
            self.topStatusLabel.text = challenge.name
        }
        
    }
    
    func timerAction() {
        counter += 1
        bottomStatus2Label.text = "Time: \(timeString(TimeInterval(counter)))"
    }
    
    
    func timeString(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    
    //MARK: EndActivity Delegate methods
    
    func endChallenge() {
        print("End Challenge")
        let firstCoordinate = self.path[0]
        let firstLat = firstCoordinate.lat
        let firstLong = firstCoordinate.long
        let locationStore = LocationStore()
        let pathArray = locationStore.createPathArray(self.path)
        let challengeTime = Double(counter)
        let dict = ["location": pathArray, "lat": firstLat,"long": firstLong, "timeToBeat": challengeTime] as [String : Any]
        
        let polyline = self.pathObject.getPolyline(self.path)
        polyline.strokeColor = .green
        polyline.strokeWidth = 3.0
        polyline.map = self.googleMapView
        
        self.challengeOn = false
        updateViews(.home)
        
        let alertController = showAlert(title: "Challenge ended", message: "Would you like to add this challenge?", useDefaultAction: false)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            
            self.challengeFirebaseRef!.updateChildValues(dict)
            self.dismiss(animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            
            self.challengeFirebaseRef?.removeValue()
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
        //self.locateMeButton.isHidden = true
        
        timer.invalidate()
        
        distance = 0.0
        //get back to original view
        setupViewHierarchy()
        configureConstraints()
        
        
    }
    
    
    //MARK: - Setup views
    private func updateViews(_ state: State) {
        let activeViews = [
            self.topStatusView,
            self.topStatusLabel,
            self.bottomStatusView,
            self.bottomStatus1Label,
            self.endButton
        ]
        
        DispatchQueue.main.async {
            switch state {
            case .home:
                self.setupViewHierarchy()
                self.eventSegmentedControl.isHidden = false
                
            case .challenge:
                self.eventSegmentedControl.isHidden = true
                _ = activeViews.map({$0.isHidden = false})
                self.topStatusView.backgroundColor = ColorPalette.orangeThemeColor
                self.bottomStatusView.backgroundColor = ColorPalette.orangeThemeColor
                
                
            case .event:
                self.eventSegmentedControl.isHidden = true
                _ = activeViews.map({$0.isHidden = false})
                self.topStatusView.backgroundColor = ColorPalette.purpleThemeColor
                self.bottomStatusView.backgroundColor = ColorPalette.purpleThemeColor
                
            }
        }
    }
    
    func setupViewHierarchy() {
        locationManager.delegate = self
        self.edgesForExtendedLayout = []
        
        //original view setup
        self.view.addSubview(googleMapView)
        self.view.addSubview(eventSegmentedControl)
        self.googleMapView.addSubview(locateMeButton)
        self.googleMapView.addSubview(addButton)
        self.googleMapView.addSubview(endButton)
        
        //challenge view setup
        self.googleMapView.addSubview(topStatusView)
        self.googleMapView.addSubview(bottomStatusView)
        self.topStatusView.addSubview(topStatusLabel)
        self.bottomStatusView.addSubview(bottomStatus1Label)
        self.bottomStatusView.addSubview(bottomStatus2Label)
        
        let activeViews = [
            self.topStatusView,
            self.topStatusLabel,
            self.bottomStatusView,
            self.bottomStatus1Label,
            self.endButton
        ]
        _ = activeViews.map({$0.isHidden = true})
    }
    
    
    
    func configureConstraints() {
        
        eventSegmentedControl.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(25.0)
            view.width.equalToSuperview().multipliedBy(0.85)
            view.height.equalTo(30.0)
            view.centerX.equalToSuperview()
        }
        
        googleMapView.snp.makeConstraints { (view) in
            view.top.bottom.leading.trailing.equalToSuperview()
        }
        
        locateMeButton.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview().inset(10)
            view.width.height.equalTo(50)
            view.bottom.equalToSuperview().inset(10)
        }
        
        addButton.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.width.height.equalTo(50)
            view.bottom.equalToSuperview().inset(10)
        }
        
        endButton.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.width.height.equalTo(50)
            view.bottom.equalTo(bottomStatusView.snp.top)
        }
        
        //challenge view configs
        topStatusView.snp.makeConstraints({ (view) in
            view.height.equalTo(50)
            view.width.equalToSuperview()
            view.top.equalToSuperview()
        })
        
        topStatusLabel.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.width.equalToSuperview().multipliedBy(0.5)
            view.height.equalToSuperview().multipliedBy(0.5)
        }
        
        
        bottomStatusView.snp.makeConstraints { (view) in
            view.height.equalTo(60)
            view.width.equalToSuperview()
            view.bottom.equalToSuperview()
        }
        
        bottomStatus1Label.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.width.equalToSuperview().multipliedBy(0.5)
            view.height.equalToSuperview().multipliedBy(0.5)
            view.top.equalToSuperview()
        }
        
        bottomStatus2Label.snp.makeConstraints { (view) in
            view.width.equalToSuperview().multipliedBy(0.5)
            view.height.equalTo(50)
            view.leading.equalTo(bottomStatus1Label.snp.leading)
            view.bottom.equalToSuperview()
        }
    }
    
    //MARK: - Views
    
    private let endButton: UIButton = {
        let button: UIButton = UIButton()
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.snp.makeConstraints({ (view) in
            view.size.equalTo(CGSize(width: 30, height: 30))
        })
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = CGSize(width: 1, height: 5)
        button.layer.shadowRadius = 2
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 25
        // button.addTarget(self, action: #selector(endChallenge), for: .touchUpInside)
        return button
    }()
    
    
    private let googleMapView: GMSMapView = {
        let mapview: GMSMapView = GMSMapView()
        mapview.translatesAutoresizingMaskIntoConstraints = false
        mapview.mapType = .normal
        mapview.isBuildingsEnabled = false
        // mapview.isMyLocationEnabled = true
        
        do {
            if let styleURL = Bundle.main.url(forResource: "darkBlueStyle", withExtension: "json") {
                mapview.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        return mapview
    }()
    
    private lazy var locationManager: CLLocationManager = {
        let locMan: CLLocationManager = CLLocationManager()
        locMan.desiredAccuracy = kCLLocationAccuracyBest
        locMan.distanceFilter = 50.0
        return locMan
    }()
    
    private let locateMeButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "locate"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.snp.makeConstraints({ (view) in
            view.size.equalTo(CGSize(width: 30, height: 30))
        })
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = CGSize(width: 1, height: 5)
        button.layer.shadowRadius = 2
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(findUser), for: .touchUpInside)
        return button
    }()
    
    internal lazy var eventSegmentedControl: UISegmentedControl = {
        var segmentedControl = UISegmentedControl()
        segmentedControl = UISegmentedControl(items: self.events)
        let font = UIFont.systemFont(ofSize: 14)
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        segmentedControl.tintColor = .white
        segmentedControl.backgroundColor = ColorPalette.greenThemeColor
        segmentedControl.addTarget(self, action: #selector(segementedControlValueChanged(sender:)), for: .valueChanged)
        return segmentedControl
    }()
    
    internal lazy var addButton: UIButton = {
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
        button.addTarget(self, action: #selector(addButtonTapped(sender:)), for: .touchUpInside)
        return button
    }()
    
    //hosting, joined activity, or challenge view
    internal lazy var topStatusView: UIView = {
        var view = UIView()
        view.layer.masksToBounds = true
        return view
    }()
    
    internal lazy var topStatusLabel: UILabel = {
        var label = UILabel()
        label.text = "Your challenge/event"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .white
        label.font.withSize(20.0)
        return label
    }()
    
    internal lazy var bottomStatusView: UIView = {
        var view = UIView()
        view.layer.masksToBounds = true
        return view
    }()
    
    internal lazy var bottomStatus1Label: UILabel = {
        var label = UILabel()
        label.text = "distance"
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    internal lazy var bottomStatus2Label: UILabel = {
        var label = UILabel()
        label.text = "time"
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
}
