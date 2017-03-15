//
//  LocationStore.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/10/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import CoreLocation

class LocationStore {
    
    func createPathArray(_ locationArray: [Location]) -> [[String:Any]] {
        
        var array: [[String:Any]] = []
        
        for location in locationArray {
            let dict = ["lat": location.latitude, "long": location.longitude]
            array.append(dict)
        }
        
        return array
    }
    
    func isUserWithinRadius(userLocation: CLLocation, challengeLocation: Location) -> Bool {
        
        let loc = CLLocation(latitude: challengeLocation.latitude, longitude: challengeLocation.longitude)
        let distance = userLocation.distance(from: loc)
        
        if  distance < 100.0 {
            return true
        }
        
        return false
    }

    
}