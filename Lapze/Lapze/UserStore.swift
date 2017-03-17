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
            if let name = snapshot.childSnapshot(forPath: "name").value as? String,
                let profilePic = snapshot.childSnapshot(forPath: "profilePic").value as? String,
                let badges = snapshot.childSnapshot(forPath: "badges").value as? [String] {
                userObject = User(id: id,
                                  name: name,
                                  profilePic: profilePic,
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
            if let name = snap.childSnapshot(forPath: "name").value as? String,
                let profilePic = snap.childSnapshot(forPath: "profilePic").value as? String,
                let badges = snap.childSnapshot(forPath: "badges").value as? [String] {
                let user = User(id: id,
                                  name: name,
                                  profilePic: profilePic,
                                  badges: badges)
                
                userObjects.append(user)
                }
            }
            completion(userObjects)
        })
    }
    
}
