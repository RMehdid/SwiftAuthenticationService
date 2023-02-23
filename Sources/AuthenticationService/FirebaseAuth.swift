//
//  Firebase.swift
//  
//
//  Created by Samy Mehdid on 23/2/2023.
//

import Foundation
import FirebaseAuth

public struct FirebasePhoneAuth {
    public static func getUser(success: @escaping (User?) -> Void) {
        success(Auth.auth().currentUser)
    }
    
    public static func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            debugPrint(signOutError.localizedDescription)
        }
    }
    
    public static func refreshToken(success: @escaping (String) -> Void) {
        getUser { currentUser in
            guard let currentUser = currentUser else {
                debugPrint("no user found")
                return
            }
            
            currentUser.getIDTokenForcingRefresh(true) { idToken, error in
                
                guard error == nil else {
                    return
                }
                
                guard let idToken = idToken else {
                    return
                }
                
                success(idToken)
            }
        }
    }
    
#if !os(macOS)
    public static func login(phone: String, success: @escaping (String) -> Void, failed: @escaping (String?) -> Void) {
        PhoneAuthProvider.provider(auth: Auth.auth())
        
        PhoneAuthProvider.provider().verifyPhoneNumber("+213\(phone)", uiDelegate: nil){ verificationID, error in
            guard let verificationID = verificationID, error == nil else {
                failed(error!.localizedDescription)
                return
            }
            
            success(verificationID)
        }
    }
    
    
    public static func verifyOTP(phone: String, verificationID: String, verificationCode: String, success: @escaping (String) -> Void) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { _, error in
            guard error == nil else {
                return
            }
            
            refreshToken { idToken in
                success(idToken)
            }
        }
    }
#endif
}
