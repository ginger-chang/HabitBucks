//
//  AuthViewModel.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/3/23.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI
import CryptoKit
import AuthenticationServices

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isLoading = true
    @Published var signInAlert = false
    @Published var createAccountAlert = false
    
    @Published var nonce = ""
    
    static let shared = AuthViewModel()
    
    init() {
        print("loading is true")
        self.userSession = Auth.auth().currentUser
        print("user session is \(self.userSession)")
        Task {
            await fetchUser()
        }
    }
    
    func giveUid() -> String {
        return self.currentUser?.id ?? ""
    }
    
    func authenticate(credential: ASAuthorizationAppleIDCredential) async throws {
        // getting token
        guard let token = credential.identityToken else {
            print("DEBUG: error with firebase authenticate")
            self.isLoading = false
            return
        }
        
        // token string
        guard let tokenString = String(data: token, encoding: .utf8) else {
            print("DEBUG: error with token")
            self.isLoading = false
            return
        }
        self.isLoading = true
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: self.nonce)
        let result = try await Auth.auth().signIn(with: firebaseCredential)
        
        // user successfully logged in to firebase
        self.userSession = result.user
        var name: String = ""
        let nameFormatter = PersonNameComponentsFormatter()
        nameFormatter.style = .default
        let user = User(id: self.userSession?.uid ?? "00000", username: nameFormatter.string(from: credential.fullName ?? PersonNameComponents()), email: self.userSession?.email ?? "error@error.com")
        let encodedUser = try Firestore.Encoder().encode(user)
        try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
        await fetchUser()
        print("log in success, result is \(result)")
        
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser() // sets self.currentUser
        } catch {
            print("DEBUG: failed to login with error \(error)")
            self.signInAlert = true
            self.createAccountAlert = false
            
        }
    }
    
    func createUser(withEmail email: String, password: String, username: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, username: username, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            print("DEBUG: failed to create user with error \(error.localizedDescription)")
            self.createAccountAlert = true
            self.signInAlert = false
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil // automatically takes us back to login view (b/c userSession is @Published)
            self.currentUser = nil
            self.isLoading = false // VERY WEIRD LOGIC
        } catch {
            print("DEBUG: failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
         
    }
    
    func fetchUser() async {
        self.isLoading = true
        guard let uid = Auth.auth().currentUser?.uid else {
            self.isLoading = false
            return
        }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else {
            self.isLoading = false
            print("is the problem here??")
            return
        }
        self.currentUser = try? snapshot.data(as: User.self)
        await TaskViewModel.shared.asyncSetup()
            //self.isLoading = false
        print("DEBUG: current user is \(self.currentUser)")
    }
    
    func constructSignInAlert() -> Alert {
        return Alert(
            title: Text("Sign In Failed"),
            message: Text("Email or password is incorrect."),
            dismissButton: .default(Text("OK"))
        )
    }
    
    func constructCreateAccountAlert() -> Alert {
        return Alert(
            title: Text("Account Create Failed"),
            message: Text("Email or password is invalid."),
            dismissButton: .default(Text("OK"))
        )
    }
    
    func loadingDone() {
        self.isLoading = false
    }
}

// helpers for sign in with apple

func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
        fatalError(
            "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
    }
    
    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    
    let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
    }
    
    return String(nonce)
}

func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()
    
    return hashString
}
