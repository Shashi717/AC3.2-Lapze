//
//  Event.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/12/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation

struct Event{
    var id: String
    let type: String
    let date: Date
    let location: Location
    
    func toJson()->[String:Any]{
        let locDic = ["lat":location.latitude,"long": location.longitude]
        return ["type":self.type,"date":DateFormatter().string(from: date),"location":locDic]
    }
    
    init(type: String,date:Date, location:Location){
        self.type = type
        self.location = location
        self.date = date
        self.id = ""
    }
    
    init(id:String,type: String,date:Date, location:Location){
        self.type = type
        self.location = location
        self.date = date
        self.id = id
    }
}
