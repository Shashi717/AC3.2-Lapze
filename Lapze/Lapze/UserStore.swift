//
//  UserStore.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/10/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase

class UserStore {
    
    let databaseRef = FIRDatabase.database().reference()
    
    func getUser(id: String, completion: @escaping (User) -> Void) {
        
        self.databaseRef.child("users").child(id).observe(.value, with: {(snapshot) in
            
            var userObject: User?
            let id = snapshot.key
            var badges:[String] = []
            if let name = snapshot.childSnapshot(forPath: "name").value as? String,
                let profilePic = snapshot.childSnapshot(forPath: "profilePic").value as? String,
                let challengeCount = snapshot.childSnapshot(forPath: "challengeCount").value as? Int,
                let eventCount = snapshot.childSnapshot(forPath: "eventCount").value as? Int {
                
                if let userBadges = snapshot.childSnapshot(forPath: "badges").value as? [String] {
                    badges = userBadges
                }
                userObject = User(id: id,
                                  name: name,
                                  profilePic: profilePic,
                                  challengeCount: challengeCount,
                                  eventCount: eventCount,
                                  badges: badges)
            }
            if let user = userObject {
                completion(user)
            }
            
        })
    }
    
    func updateUserData(id: String, values: [String: Any], child: String?) {
        if child != nil {
            self.databaseRef.child("users").child(id).child(child!).updateChildValues(values)
        } else {
            self.databaseRef.child("users").child(id).updateChildValues(values)
        }
    }
    
    func getAllUsers(completion: @escaping ([User]) -> Void) {
        var userObjects: [User] = []
        
        self.databaseRef.child("users").observe(.value, with: {(snapshot) in
            
            let enumerator = snapshot.children
            while let snap = enumerator.nextObject() as? FIRDataSnapshot {
                
                let id = snap.key
                var badges:[String] = []
                
                if let name = snap.childSnapshot(forPath: "name").value as? String,
                    let profilePic = snap.childSnapshot(forPath: "profilePic").value as? String,
                    let challengeCount = snap.childSnapshot(forPath: "challengeCount").value as? Int,
                    let eventCount = snap.childSnapshot(forPath: "eventCount").value as? Int {
                    
                    if let userBadges = snap.childSnapshot(forPath: "badges").value as? [String] {
                        badges = userBadges
                    }
                    
                    let user = User(id: id,
                                    name: name,
                                    profilePic: profilePic,
                                    challengeCount: challengeCount,
                                    eventCount: eventCount,
                                    badges: badges)
                    
                    
                    userObjects.append(user)
                }
            }
            completion(userObjects)
        })
    }
    
    func updateActivityCounts(activityType: String) {
        let userId = FirebaseManager.shared.uid!
        
        self.databaseRef.child("users").child(userId).child(activityType).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            self.databaseRef.child("users").child(userId).child(activityType).setValue(value+1)
        })
    }
    
}
