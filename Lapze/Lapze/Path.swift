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
    
    func getPolyline(_ coordinatesArr: [[String:CLLocationDegrees]] ) -> GMSPolyline {
        for dict in coordinatesArr {
            if let lat = dict["lat"], let long = dict["long"] {
                let coordinates = CLLocationCoordinate2D(latitude: lat , longitude: long)
                path.add(coordinates)
            }
        }
        return GMSPolyline(path: path)
    }
    
}
