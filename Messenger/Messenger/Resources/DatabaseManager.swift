//
//  DatabaseManager.swift
//  Messenger
//
//  Created by MRGS on 16.09.2022.
//

import UIKit
import FirebaseDatabase

final class DatabaseManager{
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    static func safeEmail(emailAdress:String) -> String {
        var safeEmail = emailAdress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    public func userExists(with email:String,completion:@escaping ((Bool)->Void)){
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else{
                completion(false)
                return
            }
            completion(true)
        }
        
    }
    public func insertUser(with user:ChatAppUser,completion: @escaping (Bool) -> Void)  {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ]) { error, _ in
            guard error == nil else {
                print("Failed ot write to database")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
}
 
struct ChatAppUser {
    let firstName:String
    let lastName:String
    let emailAdress:String
    var safeEmail:String{
        var safeEmail = emailAdress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName: String{
        return "\(safeEmail)_profile_pic.png"
    }
}
