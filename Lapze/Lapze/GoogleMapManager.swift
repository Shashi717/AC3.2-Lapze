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
    private var map: GMSMapView?
    private init(){}
    
    private var dict: [String: GMSMarker] = [:]
    
    func manage(map: GMSMapView){
        self.map = map
    }
    
    func addMarker(id: String, with locationDict:[String:Double]){
        if let lat = locationDict["lat"], let long = locationDict["long"] {
            let cllocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let marker = GMSMarker(position: cllocation)
            self.dict[id] = marker
            marker.map = map
            marker.icon = UIImage(named: "010-man")
            marker.title = id
            
        }
    }
    
    func addMarker(id: String, lat: Double, long: Double){
        if dict[id] == nil{
            let cllocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let marker = GMSMarker(position: cllocation)
            self.dict[id] = marker
            marker.map = map
            marker.icon = UIImage(named: "marker")
            marker.title = id
        }else{
            let markerTest = getMarker(id: id)
            markerTest?.position.latitude = lat
            markerTest?.position.longitude = long
        }
        
    }
    
    func addMarker(id: String, marker:GMSMarker){
        self.dict[id] = marker
        marker.map = map
    }
    func getMarker(id:String)->GMSMarker?{
        return dict[id]
    }
    
    func removeMarker(id:String){
        dict[id]?.map = nil
        dict[id] = nil
    }
    
    func updateMarker(id:String,locationDict:[String:Double]){
        if let marker = dict[id]{
            marker.position.latitude = locationDict["lat"]!
            marker.position.longitude = locationDict["long"]!
        }
    }
    
    func allMarkers()->[String:GMSMarker]{
        return dict
    }
    
    func hideAllMarkers(){
        for marker in self.dict{
            marker.value.map = nil
        }
        self.dict = [:]
    }
}
