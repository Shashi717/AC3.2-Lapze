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
            if let name = snapshot.childSnapshot(forPath: "name").value as? String {
                userObject = User(id: id,
                                  name: name)
            }
            if let user = userObject {
                completion(user)
            }
            
        })
    }
    
}
