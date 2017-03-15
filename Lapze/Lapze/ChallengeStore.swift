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
                
                let id = snap.key
                var timeToBeat: Double?
                
                if let name = snap.childSnapshot(forPath: "name").value as? String,
                    let champion = snap.childSnapshot(forPath: "champion").value as? String,
                    let lastUpdated = snap.childSnapshot(forPath: "lastUpdated").value as? String,
                    let locationArray = snap.childSnapshot(forPath: "location").value as? [[String:Double]],
                    let type = snap.childSnapshot(forPath: "type").value as? String,
                    let lat = snap.childSnapshot(forPath: "lat").value as? Double,
                    let long = snap.childSnapshot(forPath: "long").value as? Double {
                    
                    if let challengeTime = snap.childSnapshot(forPath: "timeToBeat").value as? Double {
                        timeToBeat = challengeTime
                    }
                    
                    var path: [Location] = []
                    for locationDict in locationArray {
                        let locationObject = Location(lat: locationDict["lat"]!, long: locationDict["long"]!)
                        path.append(locationObject)
                    }
                    
                    let challenge = Challenge(id: id,
                                              name: name,
                                              champion: champion,
                                              lastUpdated: lastUpdated,
                                              type: type,
                                              lat: lat,
                                              long: long,
                                              timeToBeat: timeToBeat,
                                              path: path)
                    
                    challengeArray.append(challenge)
                }
            }
            
            completion(challengeArray)
        })
        dump("challenge array >> \(challengeArray)")
    }
    
    
    func getChallenge(id: String, completion: @escaping (Challenge) -> Void) {
        
        var challenge: Challenge?
        
        self.databaseRef.child("Challenge").child(id).observe(.value, with: {(snapshot) in
            
            var lat: Double?
            var long: Double?
            var path: [Location] = []
            var timeToBeat: Double?
            
            if let name = snapshot.childSnapshot(forPath: "name").value as? String,
                let champion = snapshot.childSnapshot(forPath: "champion").value as? String,
                let lastUpdated = snapshot.childSnapshot(forPath: "lastUpdated").value as? String,
                let type = snapshot.childSnapshot(forPath: "type").value as? String {
                if let challengeTime = snapshot.childSnapshot(forPath: "timeToBeat").value as? Double {
                    timeToBeat = challengeTime
                }
                
                if let latitude = snapshot.childSnapshot(forPath: "lat").value as? Double,
                    let longitude = snapshot.childSnapshot(forPath: "long").value as? Double,
                    let locationArray = snapshot.childSnapshot(forPath: "location").value as? [[String:Double]]
                {
                    lat = latitude
                    long = longitude
                    
                    for locationDict in locationArray {
                        let locationObject = Location(lat: locationDict["lat"]!, long: locationDict["long"]!)
                        path.append(locationObject)
                    }
                }
                
                challenge = Challenge(id: id,
                                      name: name,
                                      champion: champion,
                                      lastUpdated: lastUpdated,
                                      type: type,
                                      lat: lat,
                                      long: long,
                                      timeToBeat: timeToBeat,
                                      path: path)
                
            }
            if let challenge = challenge {
                completion(challenge)
            }
        })
        
    }
    
    func getAllUserChallenges(userId: String, completion: @escaping ([Challenge]) -> Void) {
        
        var challengeArray: [Challenge] = []
        
        self.databaseRef.child("Challenge").observe(.value, with: {(snapshot) in
            let enumerator = snapshot.children
            while let snap = enumerator.nextObject() as? FIRDataSnapshot {
                
                let id = snap.key
                var timeToBeat: Double?
                
                if let name = snap.childSnapshot(forPath: "name").value as? String,
                    let champion = snap.childSnapshot(forPath: "champion").value as? String,
                    let lastUpdated = snap.childSnapshot(forPath: "lastUpdated").value as? String,
                    let locationArray = snap.childSnapshot(forPath: "location").value as? [[String:Double]],
                    let type = snap.childSnapshot(forPath: "type").value as? String,
                    let lat = snap.childSnapshot(forPath: "lat").value as? Double,
                    let long = snap.childSnapshot(forPath: "long").value as? Double {
                    
                    if let challengeTime = snap.childSnapshot(forPath: "timeToBeat").value as? Double {
                        timeToBeat = challengeTime
                    }
                    
                    var path: [Location] = []
                    for locationDict in locationArray {
                        let locationObject = Location(lat: locationDict["lat"]!, long: locationDict["long"]!)
                        path.append(locationObject)
                    }
                    
                    if champion == userId {
                    let challenge = Challenge(id: id,
                                              name: name,
                                              champion: champion,
                                              lastUpdated: lastUpdated,
                                              type: type,
                                              lat: lat,
                                              long: long,
                                              timeToBeat: timeToBeat,
                                              path: path)
                    
                    challengeArray.append(challenge)
                    }
                }
            }
            completion(challengeArray)
        })
        //dump("challenge array >> \(challengeArray)")
    }
    
 
}
