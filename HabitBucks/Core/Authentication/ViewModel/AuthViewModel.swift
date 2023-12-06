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

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isLoading = true
    
    static let shared = AuthViewModel()
    
    init() {
        print("loading is true")
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser() // sets self.currentUser
        } catch {
            print("DEBUG: failed to login with error \(error)")
        }
    }
    
    func createUser(withEmail email: String, password: String, username: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, username: username, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            // TODO: setup other databases - call helper functions (shop, tasks, pomodoro, coins, etc.)
            await fetchUser()
        } catch {
            print("DEBUG: failed to create user with error \(error.localizedDescription)")
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
            return
        }
        self.currentUser = try? snapshot.data(as: User.self)
        self.isLoading = false
        print("DEBUG: current user is \(self.currentUser)")
    }
}
