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
    
    fileprivate var markerOption: MarkerOption = .none
    fileprivate var trackingBehavior: TrackingBehavior = .none
    fileprivate var userLocationMarker: GMSMarker?
    fileprivate var viewControllerState: MapViewControllerState = .events
    fileprivate var userCurrentLocation: CLLocation?{
        didSet{
            updateUserLocationMarker(location: userCurrentLocation!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        LocationManager.sharedManager.delegate = self
        googleMapView.delegate = self
        FirebaseManager.shared.startObserving(node: .event)
    }
    
    private func setUpViewController(){
        self.view.addSubview(googleMapView)
        self.view.addSubview(locateMeButton)
        
        googleMapView.snp.makeConstraints { (view) in
            view.trailing.leading.top.bottom.equalToSuperview()
        }
        
        locateMeButton.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview().inset(10)
            view.width.height.equalTo(50)
            view.bottom.equalToSuperview().inset(10)
        }
    }
    
    public func updateMapState(state: MapViewControllerState){
        viewControllerState = state
    }
    
    //MARK:- Activity update
    public func startActivity(){
        switch viewControllerState{
        case .challenges:
            print("Challenges start")
        case .events:
            trackingBehavior = .limitedFollow//.limitedFollow(radius: 10)
            userLocationMarker?.iconView = nil
            userLocationMarker?.icon = UIImage(named: "010-man")
        }
    }
    
    public func endActivity(){
        switch viewControllerState{
        case .challenges:
            print("Challenges end")
        case .events:
            userLocationMarker?.iconView = UserLocationMarker()
            userLocationMarker?.icon = nil
        }
        trackingBehavior = .none
    }
    
    //MARK:- Location manager delegate methods
    func locationDidUpdate(newLocation: CLLocation) {
        userCurrentLocation = newLocation
        
        switch trackingBehavior{
        case .followWithPathMarking:
            print(trackingBehavior)
        case .limitedFollow:
            print(trackingBehavior)
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
    
    public func viewMarkers() {
        
    }
    
    //MARK:- Google map delegate methods
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard marker != userLocationMarker else { return nil }
        
        let view: GoogleMapThumbView = GoogleMapThumbView()
        view.profileImageView.image = marker.icon
        view.titleLabel.text = marker.title
        
        switch markerOption {
        case .event:
            view.backgroundColor = ColorPalette.purpleThemeColor
        case .challenge:
            view.backgroundColor = ColorPalette.orangeThemeColor
        case .none:
            break
        }
        return view
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
