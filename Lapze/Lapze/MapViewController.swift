//
//  MapViewController.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/9/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import GoogleMaps

protocol MapStateProtocal {
    func updateMapState(state:MapViewControllerState)
}

public enum MapViewControllerState:Int{
    case events
    case challenges
}

class MapViewController: UIViewController,LocationConsuming,GMSMapViewDelegate {
    
    fileprivate enum TrackingBehavior {
        case followWithPathMarking
        // case limitedFollow(radius:Int)
        case limitedFollow
        case none
    }
    
    fileprivate enum MarkerOption {
        case challenge
        case event
        case none
    }
    
    fileprivate var markerOption: MarkerOption = .event{
        didSet{
            updateMarkers()
        }
    }
    fileprivate var trackingBehavior: TrackingBehavior = .none
    fileprivate var userLocationMarker: GMSMarker?
    fileprivate var viewControllerState: MapViewControllerState = .events
    fileprivate var userCurrentLocation: CLLocation?{
        didSet{
            updateUserLocationMarker(location: userCurrentLocation!)
        }
    }
    
    private var previousLocation: CLLocation?
    private var allChallenges: [Challenge] = []
    private var userChampionshipChallenges: [String] = []
    private let challengeStore = ChallengeStore()
    private let userStore = UserStore()
    private let popVc: PopupViewController = PopupViewController()
    private let path: GMSMutablePath = GMSMutablePath()
    let challengePath = Path()
    let userPath = Path()
    var userPathArray: [Location] = []
    var distance: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        LocationManager.sharedManager.delegate = self
        googleMapView.delegate = self
        line.map = googleMapView
        FirebaseManager.shared.startObserving(node: .event)
        
        GoogleMapManager.shared.manage(map: self.googleMapView)
        getAllChallenges()
        
    }
    
    private func setUpViewController(){
        self.view.addSubview(googleMapView)
        self.view.addSubview(locateMeButton)
        
        googleMapView.snp.makeConstraints { (view) in
            view.trailing.leading.top.bottom.equalToSuperview()
        }
        
        locateMeButton.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview().inset(10)
            view.width.height.equalTo(40)
            view.bottom.equalToSuperview().inset(10)
        }
    }
    
    public func updateMapState(state: MapViewControllerState){
        viewControllerState = state
        switch state{
        case .challenges:
            markerOption = .challenge
        case .events:
            markerOption = .event
        }
    }
    
    //MARK:- Activity update
    public func startActivity(){
        switch viewControllerState{
        case .challenges:
            trackingBehavior = .followWithPathMarking
        case .events:
            trackingBehavior = .limitedFollow//.limitedFollow(radius: 10)
        }
        userLocationMarker?.iconView = nil
        userLocationMarker?.icon = UIImage(named: "7")
        markerOption = .none
    }
    
    public func endActivity(){
        switch viewControllerState{
        case .challenges:
            print("Challenges end")
            markerOption = .challenge
        case .events:
            markerOption = .event
        }
        userLocationMarker?.iconView = UserLocationMarker()
        userLocationMarker?.icon = nil
        trackingBehavior = .none
        
        distance = 0.0
        
    }
    
    private func updateMarkers(){
        switch markerOption {
        case .challenge:
            
            self.markChallenges(allChallenges)
            
        case .event:
            print("event markers")
        case .none:
            print("show no markers")
        }
    }
    
    //MARK:- Challenge Utilities
    private func getAllChallenges(){
        challengeStore.getAllChallenges { (challenges) in
            self.allChallenges = challenges
            self.userChampionshipChallenges = self.getUsersChampionships(challenges)
        }
    }
    
    private func getUsersChampionships(_ challenges: [Challenge]) -> [String] {
        var challengeIds: [String] = []
        
        for challenge in challenges {
            if challenge.champion == FirebaseManager.shared.uid {
                challengeIds.append(challenge.id)
            }
        }
        return challengeIds
    }
    
    private func markChallenges(_ challenges: [Challenge]) {
        for challenge in challenges {
            if self.userChampionshipChallenges.contains(challenge.id) {
                GoogleMapManager.shared.addMarker(id: challenge.id, lat: challenge.lat!, long: challenge.long!, imageName: "crown")
            }
            else {
                GoogleMapManager.shared.addMarker(id: challenge.id, lat: challenge.lat!, long: challenge.long!, imageName: challenge.type)
            }
        }
    }
    
    
    //MARK:- Location manager delegate methods
    func locationDidUpdate(newLocation: CLLocation) {
        userCurrentLocation = newLocation
        
        switch trackingBehavior{
        case .followWithPathMarking:
            trackDistance()
            addLocationToPathArray(newLocation)
            addPolyline(newLocation)
        case .limitedFollow:
            trackDistance()
        case .none:
            print(trackingBehavior)
        }
    }
    
    func locationUnreachable() {
        print("Error getting location")
    }
    
    //MARK:- Location Utilities
    private func updateUserLocationMarker(location: CLLocation){
        let locationCordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        if userLocationMarker == nil{
            userLocationMarker = GMSMarker(position: locationCordinate)
            userLocationMarker?.iconView = UserLocationMarker()
            userLocationMarker?.map = googleMapView
        }else{
            userLocationMarker?.position = locationCordinate
        }
    }
    
    @objc private func goToUserLocation(){
        if let location = userCurrentLocation{
            let clocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            googleMapView.animate(toLocation: clocation)
            googleMapView.animate(toZoom: 15)
        }
    }
    
    private func trackDistance(){
        let currentLocation = LocationManager.sharedManager.currentLocation
        if previousLocation != nil {
            let lastDistance = currentLocation?.distance(from: previousLocation as CLLocation!)
            distance += lastDistance!
        }
        
        previousLocation = currentLocation
    }
    
    //MARK:- Polyline Utilities
    private func addPolyline(_ location: CLLocation){
        let cllcorddinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        self.path.add(cllcorddinate)
        self.line.path = path
    }
    
    private func addUserPath(){
        guard userPathArray.count > 0 else { return }
        let pathJsonArray = userPath.toJson(array: userPathArray)
    }
    
    private func addLocationToPathArray(_ location:CLLocation){
        let location = Location(location: location)
        userPathArray.append(location)
    }
    
    public func removeUserPath(){
        path.removeAllCoordinates()
        line.path = nil
        line.map = nil
        line.map = googleMapView
    }
    //MARK:- Google map delegate methods
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard marker != userLocationMarker else { return nil }
        
        
        let thumbView: GoogleMapThumbView = GoogleMapThumbView()
        thumbView.profileImageView.image = marker.icon
        marker.tracksInfoWindowChanges = true
        
        switch markerOption {
        case .event:
            thumbView.backgroundColor = ColorPalette.purpleThemeColor
        case .challenge:
            thumbView.backgroundColor = ColorPalette.orangeThemeColor
            userPath.removePolyline()
            if let id = marker.title {
                challengeStore.getChallenge(id: id) { (challenge) in
                    self.userStore.getUser(id: challenge.champion, completion: { (user) in
                        thumbView.currentChampionNameLabel.text = ("Champion: \(user.name)")
                    })
                    
                    if self.userChampionshipChallenges.contains(id) {
                        thumbView.profileImageView.image = UIImage(named: "crown")
                    }
                    else {
                        thumbView.profileImageView.image = UIImage(named: challenge.type)
                    }
                    
                    thumbView.titleLabel.text = challenge.name
                    thumbView.descriptionLabel.text = ("\(challenge.type), \(challenge.lastUpdated) ")
                    if let challengePath = challenge.path {
                        let polyline = self.challengePath.getPolyline(challengePath)
                        polyline.strokeColor = .cyan
                        polyline.strokeWidth = 3.0
                        polyline.map = self.googleMapView
                    }
                }
            }
            
        case .none:
            return nil
        }
        return thumbView
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        challengePath.removePolyline()
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        switch viewControllerState{
        case .challenges:
            popVc.segment = 1
            if let id = marker.title {
                challengeStore.getChallenge(id: id) { (challenge) in
                    self.userStore.getUser(id: challenge.champion, completion: { (user) in
                        self.popVc.challengeDescriptionLabel.text = "\(user.name): Champion since \(challenge.lastUpdated) "
                        
                    })
                    self.popVc.activityId = challenge.id
                    self.popVc.userLocation = LocationManager.sharedManager.currentLocation
                    self.popVc.challengeNameLabel.text = challenge.name
                    self.popVc.challengeStatsLabel.text = "\(challenge.type)"
                    if let lat = challenge.lat, let long = challenge.long {
                        self.popVc.challengeLocation = Location(lat: lat , long: long)
                    }
                }
            }
            self.present(popVc, animated: true, completion: nil)
        case .events:
            print("Events")
        }
    }
    // MARK:- Views
    private let googleMapView: GMSMapView = {
        let mapview: GMSMapView = GMSMapView()
        mapview.translatesAutoresizingMaskIntoConstraints = false
        mapview.mapType = .normal
        mapview.isBuildingsEnabled = false
        
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
    
    
    
    private lazy var line: GMSPolyline = {
        let polyline: GMSPolyline = GMSPolyline()
        polyline.strokeColor = .green
        polyline.strokeWidth = 3
        polyline.geodesic = true
        return polyline
    }()
    
    let locateMeButton: UIButton = {
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
        button.addTarget(self, action: #selector(goToUserLocation), for: .touchUpInside)
        return button
    }()
}
