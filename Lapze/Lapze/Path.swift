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
    
    private let path = GMSMutablePath()
    private var polyline = GMSPolyline()
    
    func getPolyline(_ coordinatesArr: [Location] ) -> GMSPolyline {
         path.removeAllCoordinates()
        for location in coordinatesArr {
            let lat = location.lat
            let long = location.long
            let coordinates = CLLocationCoordinate2D(latitude: lat , longitude: long)
            path.add(coordinates)
        }
        polyline.path = path
        return polyline
    }
    
    func removePolyline() {
        polyline.map = nil
    }
}
