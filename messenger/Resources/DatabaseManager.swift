//
//  DatabaseManager.swift
//  messenger
//
//  Created by sotatek on 07/09/2023.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
}

// MARK: - Account Management

extension DatabaseManager {
    
    public func emailExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        var safeEmail: String {
            var safeEmail = email.replacingOccurrences(of: ".", with: "-")
            safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
            return safeEmail
        }

        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value is String else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// Insert new user to database
    public func inserUser(with user: ChatAppUser) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
        ])
    }

}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let email: String
    
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
