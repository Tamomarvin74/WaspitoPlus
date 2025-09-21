//
//    AuthService.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/16/25.
//

import Foundation
import FirebaseAuth

final class AuthService {
    static let shared = AuthService()
    private init() {}
    
    func register(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let firebaseUser = authResult?.user {
                let user = User(id: firebaseUser.uid, displayName: firebaseUser.displayName, email: firebaseUser.email)
                UserDefaults.standard.set(firebaseUser.uid, forKey: "currentUserId")
                completion(.success(user))
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let firebaseUser = authResult?.user {
                let user = User(id: firebaseUser.uid, displayName: firebaseUser.displayName, email: firebaseUser.email)
                UserDefaults.standard.set(firebaseUser.uid, forKey: "currentUserId")
                completion(.success(user))
            }
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        UserDefaults.standard.removeObject(forKey: "currentUserId")
    }
    
    var isLoggedIn: Bool {
        return UserDefaults.standard.string(forKey: "currentUserId") != nil
    }
}

