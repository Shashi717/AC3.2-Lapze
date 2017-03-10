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
    
    //    func getAllChallenges(completion: @escaping ([User]) -> Void) {
    //
    //        var challengeArray: [User] = []
    //
    //        self.databaseRef.child("users").observe(.value, with: {(snapshot) in
    //            let enumerator = snapshot.children
    //            while let snap = enumerator.nextObject() as? FIRDataSnapshot {
    //
    //                let id = snap.key
    //
    //
    //                if let name = snap.childSnapshot(forPath: "name").value as? String {
    //
    //                    let userObject = User(id: id,
    //                                               name: name)
    //
    //                    challengeArray.append(userObject)
    //                }
    //            }
    //
    //            completion(userArray)
    //        })
    //    }
    
    func getUser(id: String, completion: @escaping (User) -> Void) {
        
        self.databaseRef.child("users").child(id).observe(.value, with: {(snapshot) in
            let enumerator = snapshot.children
            while let snap = enumerator.nextObject() as? FIRDataSnapshot {
                
                let id = snap.key
                
                
                if let name = snap.childSnapshot(forPath: "name").value as? String {
                    
                    let userObject = User(id: id,
                                          name: name)
                    completion(userObject)
                }
            }
            
            
        })
    }
    
    
}
