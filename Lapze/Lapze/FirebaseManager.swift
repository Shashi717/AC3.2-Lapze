//
//  FireBaseObserverManager.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/6/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import Firebase

class FirebaseManager {
    static let shared: FirebaseManager  = FirebaseManager()
    let uid = FIRAuth.auth()?.currentUser?.uid
    private let databaseReference = FIRDatabase.database().reference()
    private var childAddedhandler: UInt?
    private var childRemovedhandler: UInt?
    private var childChangedhandler: UInt?
    private init(){}
    
    enum FirebaseNode: String{
        case location,event
    }
    
    func startObserving(node: FirebaseNode){
        let childRef = databaseReference.child(node.rawValue.capitalized)
        
        childAddedhandler = childRef.observe(.childAdded, with: { (snapshot) in
            if let event = EventStore.manager.createEvent(snapshot: snapshot){
                GoogleMapManager.shared.addMarker(event: event)
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
        databaseReference.removeAllObservers()
    }
    
    func addToFirebase(event: Event){
        let childRef = databaseReference.child("Event").child(uid!)
        childRef.updateChildValues(event.toJson()) { (error, ref) in
            if error != nil{
                print(error!.localizedDescription)
            }else{
                print("Success posting event")
            }
        }
    }
    
    func removeEvent(){
        let childRef = databaseReference.child("Event").child(uid!)
        childRef.removeValue()
    }
    
    func removeUserLocation(){
        let childRef = databaseReference.child("Location").child(uid!)
        childRef.removeValue()
    }
    
    func updateFirebase(closure: (FIRDatabaseReference) -> Void) {
        closure(databaseReference)
    }
    
    func addToFirebase(location: Location){
        let childRef = databaseReference.child("Location").child(uid!)
        childRef.updateChildValues(location.toJson()) { (error, ref) in
            if error != nil{
                print(error!.localizedDescription)
            }else{
                print("Success posting location")
            }
        }
    }
    
    func addToFirebase(challenge: Challenge){
        
    }
    
    private func getSnapshotValue(snapshot: FIRDataSnapshot)->[String:Double]?{
        return snapshot.value as? [String:Double]
    }
    
}
