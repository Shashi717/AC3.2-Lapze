//
//  ChallengeStore.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/9/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase

class ChallengeStore {
    
    let databaseRef = FIRDatabase.database().reference()
    
    func getAllChallenges(completion: @escaping ([Challenge]) -> Void) {
        
        var challengeArray: [Challenge] = []
        
        self.databaseRef.child("Challenge").observe(.value, with: {(snapshot) in
            let enumerator = snapshot.children
            while let snap = enumerator.nextObject() as? FIRDataSnapshot {
                
                let challengeId = snap.key
                
                
                if let challengeName = snap.childSnapshot(forPath: "name").value as? String,
                    let champion = snap.childSnapshot(forPath: "champion").value as? String,
                    let lastUpdated = snap.childSnapshot(forPath: "lastUpdated").value as? String,
                    let location = snap.childSnapshot(forPath: "location").value as? [[String:Double]],
                    let type = snap.childSnapshot(forPath: "type").value as? String,
                    let lat = snap.childSnapshot(forPath: "lat").value as? Double,
                    let long = snap.childSnapshot(forPath: "long").value as? Double {
                    
                    let challengeObject = Challenge(id: challengeId,
                                                    name: challengeName,
                                                    champion: champion,
                                                    lastUpdated: lastUpdated,
                                                    type: type,
                                                    lat: lat,
                                                    long: long,
                                                    location: location)
                    
                    challengeArray.append(challengeObject)
                }
            }
            
            completion(challengeArray)
        })
    }
    
    
}
