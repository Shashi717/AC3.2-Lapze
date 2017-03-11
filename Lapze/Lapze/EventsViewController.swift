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
            findUser()
            //addLocationtoFireBase(location: userLocation!)
            updateUserLocationMarker(location: userLocation!)
        }
    }
    
    private let events: [Event.RawValue] = [Event.currentEvents.rawValue, Event.challenges.rawValue]
    
    private var challengeFirebaseRef: FIRDatabaseReference?
    private let databaseRef = FIRDatabase.database().reference()
    private var challengeOn = false
    private var state: State = .home
    
    private var path: [[String: CLLocationDegrees]] = []
    
    private var userCreatedEvent: Bool = false
    private var currentUser = FIRAuth.auth()?.currentUser
    private var timer = Timer()
    private var counter = 0
    
    private var userLocationMarker: GMSMarker?
    private var previousLocation: CLLocation?
    private var showUserLocation: Bool = true
    private var distance: Double = 0.0
    private var allChallenges: [Challenge] = []
    private var eventOn = false
    
    private let challengeStore = ChallengeStore()
    private let userStore = UserStore()


    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Open Events"
        setupViewHierarchy()
        configureConstraints()
        
        //initial view of events
        self.eventSegmentedControl.selectedSegmentIndex = 0
        
        //tap gesture
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        view.addGestureRecognizer(tap)
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

            //            var name = ""
            //            let user = userStore.getUser(id: challenge.champion, completion: { (user) in
            //                name = user.name
            //            })
            //
            GoogleMapManager.shared.addMarker(id: challenge.id, lat: challenge.lat, long: challenge.long)

        }
        
    }
    
    
    //MARK: - Utilities
    deinit {
        print("View died")
    }
    
    func segementedControlValueChanged(sender: UISegmentedControl) {
        let segment = eventSegmentedControl.selectedSegmentIndex
        let popVc = PopupViewController()
        switch segment {
        case 0:
            
            print("\(events[0])")
            //thumbButton.setTitle("Join", for: .normal)
            self.navigationItem.title = "Current Events"
            self.addButton.backgroundColor = ColorPalette.purpleThemeColor
            popVc.segment = 0
            
        case 1:
            print("\(events[1])")
            GoogleMapManager.shared.hideAllMarkers()
            //thumbButton.setTitle("Challenge", for: .normal)
            self.navigationItem.title = "Challenge"
            self.addButton.backgroundColor = ColorPalette.orangeThemeColor
            popVc.segment = 1
            self.markChallenges(allChallenges)
        default:
            print("none")
        }
    }
    
    func fillPopupForCreateEvent() {
        thumbStatContainerView.backgroundColor = ColorPalette.purpleThemeColor
        thumbProfileImageView.layer.borderColor = ColorPalette.orangeThemeColor.cgColor
    }
    
    func fillPopupForChallenge() {
        thumbStatContainerView.backgroundColor = ColorPalette.orangeThemeColor
        thumbProfileImageView.layer.borderColor = ColorPalette.purpleThemeColor.cgColor
    }
    
    func fillMockupDataForThumbView() {
        thumbUserNameLabel.text = "CoolGuy123"
        thumbChallengeDescriptionLabel.text = "Bike Champ"
        thumbChallengeStatsLabel.text = "Ran 10 mile in 1 hr"
    }
    
    //MARK: - Setup Utilities
    
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
    
    func eventPopup() {
        print("want to join this event?")
        //popup box
        thumbButton.setImage(UIImage(named: "Join3"), for: .normal)
        fillPopupForCreateEvent()
        fillMockupDataForThumbView()
        self.thumbStatContainerView.isHidden = false
        //self.view.addSubview(blurView)
    }
    
    func dismissPopup() {
        print("tap gesture")
        self.thumbStatContainerView.isHidden = true
        //self.blurView.removeFromSuperview()
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
        
        let locationDict = ["lat": validLocation.coordinate.latitude, "long": validLocation.coordinate.longitude ]
        
        if challengeOn == true {
            
            
            path.append(locationDict)
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
        let view: GoogleMapThumbView = GoogleMapThumbView()
        view.profileImageView.image = marker.icon
        
        
        //        view.nameLabel.text = marker.title

        //        view.descriptionLabel.text = marker.accessibilityValue

     
        
        let selectedSegmentIndex = eventSegmentedControl.selectedSegmentIndex
        
        switch selectedSegmentIndex {
        case 0:
            //event
            
            view.backgroundColor = ColorPalette.purpleThemeColor
        case 1:
            //challenge
            view.backgroundColor = ColorPalette.orangeThemeColor
            
            if let id = marker.title {
                
                challengeStore.getChallenge(id: id) { (challenge) in
                    


                    view.nameLabel.text = challenge.name
                    view.descriptionLabel.text = ("\(challenge.type), \(challenge.champion), \(challenge.lastUpdated) ")
                }
            }
            
        default:
            break
        }
        return view
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
            self.present(popVc, animated: true, completion: nil)
        default:
            break
        }
    }
    
    //MARK: Event Delegate methods
//    func startEvent(name: String) {
//        let eventPopUp: PopupViewController = PopupViewController()
//        eventPopUp.challengeDescriptionLabel.text = "You just created a\(name) event!"
//        eventPopUp.challengeDescriptionLabel.font = UIFont.boldSystemFont(ofSize: 20)
//        eventPopUp.modalTransitionStyle = .crossDissolve
//        eventPopUp.modalPresentationStyle = .overCurrentContext
//        present(eventPopUp, animated: true, completion: nil)
//    }
    
    
    //MARK: Challenge Delegate methods
    func startChallenge(user: String, linkRef: FIRDatabaseReference) {
        print("Challenge started \(user)")
        self.challengeOn = true
        
        self.challengeFirebaseRef = linkRef
        linkRef.updateChildValues(["champion": user])
        
        self.state = .challenge
        updateViews(.challenge)

        //delete setupChallenge

        
        self.databaseRef.child("users").child(user).child("name").observe(.value, with: { (snapshot) in
            let name = snapshot.value as! String
            
            self.topStatusLabel.text = "Your Challenge"
            print("name: \(name)")
        })
        
        self.endButton.addTarget(self, action: #selector(endChallenge), for: .touchUpInside)
        //timer
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    func timerAction() {
        counter += 1
        bottomStatus2Label.text = "Time: \(counter)"
    }
    
    
    //MARK: EndActivity Delegate methods
    
    func endChallenge() {
        print("End Challenge")
        
        let alertController = showAlert(title: "Challenge ended", message: "Champion mastah", useDefaultAction: true)
        self.present(alertController, animated: true, completion: nil)
        
        
        self.challengeOn = false
        updateViews(.home)
        
        let firstCoordinate = path[0]
        if let firstLat = firstCoordinate["lat"],
            let firstLong = firstCoordinate["long"] {
            let dict = ["location": path, "lat": firstLat,"long": firstLong] as [String : Any]
            
            self.challengeFirebaseRef!.updateChildValues(dict)
        }
        let pathObject = Path()
        let polyline = pathObject.getPolyline(path)
        polyline.strokeColor = .green
        polyline.strokeWidth = 3.0
        polyline.map = googleMapView
        
        
        timer.invalidate()
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
                //_ = activeViews.map({$0.isHidden = true})
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
            view.height.equalTo(60)
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
            view.leading.equalTo(endButton.snp.trailing)
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
    
    internal lazy var thumbStatContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = false
        return view
    }()
    internal lazy var thumbProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25.0
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = false
        return imageView
    }()
    internal lazy var thumbUserNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    internal lazy var thumbChallengeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    internal lazy var thumbChallengeStatsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    internal lazy var thumbButton: UIButton = {
        let button = UIButton()
        // button.titleLabel!.font =  UIFont(name: "System - System", size: 5)
        // button.backgroundColor = ColorPalette.logoGreenColor
        //        button.layer.cornerRadius = 10.0
        //        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(thumbButtonTapped(sender:)), for: .touchUpInside)
        return button
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
        view.backgroundColor = .red
        return view
    }()
    
    internal lazy var topStatusLabel: UILabel = {
        var label = UILabel()
        label.text = "title of activity here"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .white
        return label
    }()
    
    internal lazy var bottomStatusView: UIView = {
        var view = UIView()
        view.layer.masksToBounds = true
        view.backgroundColor = .red
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
