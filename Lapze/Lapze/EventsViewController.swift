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


class EventsViewController:UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate,EventDelegate,ChallengeDelegate{

    private var userLocation: CLLocation?{
        didSet{
            findUser()
            //addLocationtoFireBase(location: userLocation!)
        }
    }
    
    let events: [Event.RawValue] = [Event.currentEvents.rawValue, Event.challenges.rawValue]

    let databaseRef = FIRDatabase.database().reference()
    var challengeRef: FIRDatabaseReference!
    var challengeOn = false
    var path: [[String: CLLocationDegrees]] = [[:]]
    var challengeLocationLatArray: [CLLocationDegrees] = []
    var challengeLocationLongArray: [CLLocationDegrees] = []
    private var userCreatedEvent: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Current Events"
//        navigationItem.leftBarButtonItem = addChallengeButton
//        navigationItem.rightBarButtonItem = endChallengeButton
        setupViewHierarchy()
        configureConstraints()
        
        //initial view of events
        self.eventSegmentedControl.selectedSegmentIndex = 0
        
        //tap gesture
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        view.addGestureRecognizer(tap)
        GoogleMapManager.shared.manage(map: self.googleMapView)
        googleMapView.delegate = self

        FirebaseObserver.manager.startObserving(node: .location)

        //Change Map view to reflect part session/challenge
        if challengeOn {
            print("you're in a challenge")
        } else {
            print("not in a challenge")
        }
        
        locationManager.delegate = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationManager.requestAlwaysAuthorization()

    }
    override func viewDidDisappear(_ animated: Bool) {
        FirebaseObserver.manager.stopObserving()
    }
    


    override func viewWillAppear(_ animated: Bool) {
        FirebaseObserver.manager.startObserving(node: .location)
        if challengeOn {
            print("you're in a challenge")
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
            //thumbButton.setTitle("Challenge", for: .normal)
            self.navigationItem.title = "Challenge!"
            self.addButton.backgroundColor = ColorPalette.orangeThemeColor
            popVc.segment = 1
        default:
            print("none")
        }
    }
    
    func fillPopupForCreateEvent() {
        //popupContainerView.backgroundColor = ColorPalette.purpleThemeColor
        //profileImageView.layer.borderColor = ColorPalette.orangeThemeColor.cgColor
        
        thumbStatContainerView.backgroundColor = ColorPalette.purpleThemeColor
        thumbProfileImageView.layer.borderColor = ColorPalette.orangeThemeColor.cgColor
    }
    
    func fillPopupForChallenge() {
        //popupContainerView.backgroundColor = ColorPalette.orangeThemeColor
        //profileImageView.layer.borderColor = ColorPalette.purpleThemeColor.cgColor
        
        thumbStatContainerView.backgroundColor = ColorPalette.orangeThemeColor
        thumbProfileImageView.layer.borderColor = ColorPalette.purpleThemeColor.cgColor
    }
    
    func fillMockupDataForThumbView() {
        thumbUserNameLabel.text = "CoolGuy123"
        thumbChallengeDescriptionLabel.text = "Bike Champ"
        thumbChallengeStatsLabel.text = "Ran 10 mile in 1 hr"
    }
    
    func challengeView() {
        self.googleMapView.addSubview(timerButton)
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
            let createEventVc = CreateChallengeViewController()
            createEventVc.delegate = self
            self.show(createEventVc, sender: self)
            
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
    

    
    //MARK: - Setup views
    //original view setup


    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        self.view.addSubview(googleMapView)
        self.view.addSubview(eventSegmentedControl)
        self.googleMapView.addSubview(locateMeButton)
        self.googleMapView.addSubview(addButton)


//        let item2 = UIBarButtonItem(customView: testButton)
//        self.navigationItem.setRightBarButton(item2, animated: true)
        

        locationManager.delegate = self
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
    }
    

    //activity view setup
    func setupViewHierarchyForActivity() {
        self.edgesForExtendedLayout = []
        self.view.addSubview(googleMapView)
        self.googleMapView.addSubview(topStatusView)
    }
    
    func configureConstraintsForActivityViews () {
        topStatusView.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
            view.width.equalToSuperview()
            view.height.equalTo(50)
        }
    }
    
    func setupActivityView() {
        hideViews()
        setupViewHierarchyForActivity()
        configureConstraintsForActivityViews()
    }
    
    func hideViews() {
        _ = [
            self.eventSegmentedControl,
            self.addButton
            ].map({$0.isHidden = true})
    }
    
    //MARK: Location Utilities

    private func addUserToMap(){
        
    }
    


    func createChallenge(sender: UIBarButtonItem) {
     
        if challengeOn == true {
            let alertController = showAlert(title: "Create Challenge Unsuccessful", message: "You are already on a challenge! Please end the current challenge to create a new challenge.", useDefaultAction: true)
               self.present(alertController, animated: true, completion: nil)
            
            
        }
        else {
        
        challengeOn = true
        challengeRef = databaseRef.child("Challenge").childByAutoId()
        challengeRef.updateChildValues(["champ": "Sam"])

    }
    
    func endChallenge(sender: UIBarButtonItem) {
        
        challengeOn = false
        challengeRef.updateChildValues(["location":path])
        
        let pathObject = Path()
        let polyline = pathObject.getPolyline(path)
        polyline.strokeColor = .green
        polyline.strokeWidth = 3.0
        polyline.map = googleMapView
        
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

    func addLocationtoFireBase(location: CLLocation){
        let childRef = FirebaseObserver.manager.dataBaseRefence.child("Location").child((FIRAuth.auth()?.currentUser?.uid)!)
        childRef.updateChildValues(["lat": location.coordinate.latitude,"long":location.coordinate.longitude]) { (error, ref) in
            
            if error != nil{
                print(error!.localizedDescription)
                
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
    var previousLocation: CLLocation?
    var distance: Double = 0.0
    

    
    //MARK: Location manager Delegate methods

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let validLocation: CLLocation = locations.last else { return }
        self.userLocation = validLocation
        if challengeOn == true {
            let locationDict = ["lat": validLocation.coordinate.latitude, "long": validLocation.coordinate.longitude ]

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
        view.nameLabel.text = marker.title
        
        let selectedSegmentIndex = eventSegmentedControl.selectedSegmentIndex
        
        switch selectedSegmentIndex {
        case 0:
            view.backgroundColor = ColorPalette.purpleThemeColor
        case 1:
            view.backgroundColor = ColorPalette.orangeThemeColor
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
    func startEvent() {
        print("Event started")
    }
    
    //MARK: Challenge Delegate methods
    func startChallenge() {
        print("Challenge started")
    }
    
    //MARK: - Views
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
    
    internal lazy var eventSegmentedControl: UISegmentedControl! = {
        var segmentedControl = UISegmentedControl()
        segmentedControl = UISegmentedControl(items: self.events)
        let font = UIFont.systemFont(ofSize: 14)
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        segmentedControl.tintColor = .white
        segmentedControl.backgroundColor = ColorPalette.greenThemeColor
        segmentedControl.addTarget(self, action: #selector(segementedControlValueChanged(sender:)), for: .valueChanged)
        return segmentedControl
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
    
    internal lazy var timerButton: UIButton! = {
        let button: UIButton = UIButton()
        button.setTitle("timer", for: .normal)
        //button.addTarget(self, action: #selector(), for: .touchUpInside)
        return button
    }()


    internal lazy var addChallengeButton: UIBarButtonItem! = {
        var barButton = UIBarButtonItem()
        barButton = UIBarButtonItem(title: "Create Challenge", style: .done, target: self, action: #selector(createChallenge(sender:)))
        return barButton
    }()
    
    internal lazy var endChallengeButton: UIBarButtonItem! = {
        var barButton = UIBarButtonItem()
        barButton = UIBarButtonItem(title: "End", style: .done, target: self, action: #selector(endChallenge(sender:)))
        return barButton
    }()

    
    //hosting, joined activity, or challenge view
    internal lazy var topStatusView: UIView! = {
        var view = UIView()
        view.layer.masksToBounds = true
        return view
    }()
    
    internal lazy var topStatusLabel: UILabel! = {
        var label = UILabel()
        label.text = "Activity joined/challenged"
        return label
    }()

}

