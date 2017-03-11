//
//  Path.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/8/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class Path {
    
    let path = GMSMutablePath()
    
    func getPolyline(_ coordinatesArr: [Location] ) -> GMSPolyline {
        for location in coordinatesArr {
            let lat = location.lat
            let long = location.long
            let coordinates = CLLocationCoordinate2D(latitude: lat , longitude: long)
            path.add(coordinates)
        }
        return GMSPolyline(path: path)
    }
    
    func removePolyline() {
        path.removeAllCoordinates()
    }
}
