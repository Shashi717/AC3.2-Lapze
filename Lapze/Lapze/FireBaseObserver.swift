//
//  FireBaseObserverManager.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/6/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import Firebase

class FirebaseObserver{
    static let manager: FirebaseObserver  = FirebaseObserver()
    let dataBaseRefence = FIRDatabase.database().reference()
    private var childAddedhandler: UInt?
    private var childRemovedhandler: UInt?
    private var childChangedhandler: UInt?
    private init(){}
    
    enum FireBaseNode: String{
        case location,event
    }
    
    func startObserving(node: FireBaseNode){
        let childRef = dataBaseRefence.child(node.rawValue.capitalized)
        
        childAddedhandler = childRef.observe(.childAdded, with: { (snapshot) in
            if let dict = self.getSnapshotValue(snapshot: snapshot){
                GoogleMapManager.shared.addMarker(id: snapshot.key, with: dict)
            }
        })
        
        childChangedhandler = childRef.observe(.childChanged, with: { (snapshot) in
            if let dict = self.getSnapshotValue(snapshot: snapshot){
                GoogleMapManager.shared.updateMarker(id: snapshot.key, locationDict: dict)
            }
        })
        
        childRemovedhandler = childRef.observe(.childRemoved, with: { (snapshot) in
                GoogleMapManager.shared.removeMarker(id: snapshot.key)
        })
    }
    
    func stopObserving(){
        dataBaseRefence.removeAllObservers()
    }
    
    private func getSnapshotValue(snapshot: FIRDataSnapshot)->[String:Double]?{
        return snapshot.value as? [String:Double]
    }

}
