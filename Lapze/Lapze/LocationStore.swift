//
//  LocationStore.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/10/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation

class LocationStore {
    
    func createPathArray(_ locationArray: [Location]) -> [[String:Any]] {
        
        var array: [[String:Any]] = []
        
        for location in locationArray {
            let dict = ["lat": location.lat, "long": location.long]
            array.append(dict)
        }
        
        return array
    }
    
}
