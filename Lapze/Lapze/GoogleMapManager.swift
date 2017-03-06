//
//  GoogleMarker.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/6/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import GoogleMaps

class GoogleMapManager{
    static let shared: GoogleMapManager = GoogleMapManager()
    public var map: GMSMapView?
    private init(){}
    
    private var dict: [String: GMSMarker] = [:]
    
    static func manage(map: GMSMapView){
        self.map = map
    }
    
    func addMarkerToDic(name: String, with dict:[String:Double]){
        if let lat = dict["lat"], let long = dict["long"] {
            let cllocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let marker = GMSMarker(position: cllocation)
            self.dict[name] = marker
            marker.map = map
            marker.title = name
        }
    }
    
    func getMarker(name:String)->GMSMarker?{
        return dict[name]
    }
    
    func removeMarker(name:String){
        dict[name]?.map = nil
        dict[name] = nil
    }
    
    func updateMarker(name:String,value:[String:Double]){
        if let marker = dict[name]{
            marker.position.latitude = value["lat"]!
            marker.position.longitude = value["long"]!
        }
    }
    
    func allMarkers()->[String:GMSMarker]{
        return dict
    }
    
}
