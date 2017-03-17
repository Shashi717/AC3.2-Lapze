//
//  EventStore.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/16/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import Firebase
class EventStore{
    static let manager: EventStore = EventStore()
    private init(){}
    
    func getAllCurrentEvents(closure:@escaping ([Event])->Void){
        var returnArray: [Event] = []
        FirebaseManager.shared.updateFirebase { (ref) in
            let childRef = ref.child("Event")
            childRef.observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children{
                    dump(child)
                    guard  let snap = child as? FIRDataSnapshot else { return }
                    
                    if let event = self.createEvent(snapshot: snap){
                        returnArray.append(event)
                    }
                }
                closure(returnArray)
            })
        }
    }
    
    func createEvent(snapshot: FIRDataSnapshot)->Event?{
        guard let valueDic = snapshot.value as? [String:Any] else { return nil }
        
        if let type = valueDic["type"] as? String,
            let date = valueDic["date"] as? String,
            let locationDic = valueDic["location"] as? [String:Double]{
            guard let lat = locationDic["lat"], let long = locationDic["long"] else { return nil }
            
            let location = Location(lat: lat, long: long)
            let event = Event(id: snapshot.key, type: type, date: Date(), location: location)
            return event
        }
        return nil
    }
}
