//
//  CoinManager.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/4/23.
//

import Foundation
import Combine
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class CoinManager: ObservableObject {
    @Published var coins: Int
    private var uid: String
    
    private var db = Firestore.firestore()
    private var default_string = ""
    
    private var cancellables: Set<AnyCancellable> = []
    
    static let shared = CoinManager()
    
    init() {
        print("coin manager init is called")
        self.coins = 0
        self.uid = ""
    }
    
    func addCoins(n: Int) {
        coins += n
        updateFirestore()
    }
    
    func minusCoins(n: Int) {
        coins -= n
        updateFirestore()
    }
    
    private func updateFirestore() {
        if self.uid == "" {
            guard case let self.uid = Auth.auth().currentUser?.uid else {
                print("Something went wrong wuwuwu \(self.uid)")
                return
            }
        }
        print("update coin firestore, uid is \(self.uid)")
        // check if document doesn't exist, add another
        let collection = db.collection("coins")
        let documentReference = collection.document(self.uid)
        documentReference.getDocument { (document, error) in
            if let error = error {
                print("DEBUG: failed to fetch coin doc with error \(error.localizedDescription)")
            } else {
                // Check if the document exists
                if let document = document, document.exists {
                    // Document exists -> update document
                    documentReference.updateData([
                        "total_coins": self.coins,
                    ]) { error in
                        if let error = error {
                            print("DEBUG: Error updating coin document: \(error)")
                        }
                    }
                }
            }
        }
        
    }
    
    // TODO: when should this be called?
    // This is called every time profile view is set up
    // Sets up subscription, add new document if needed, else update the "coins" field according what is in the database
    func setupSubscription() async {
        // set up subscription to uid
        await AuthViewModel.shared.$currentUser
            .sink { [weak self] newUser in
                self?.uid = newUser?.id ?? ""
            }
            .store(in: &cancellables)
        // check if document doesn't exist, add another
        let collection = db.collection("coins")
        let documentReference = collection.document(self.uid)
        documentReference.getDocument { (document, error) in
            if let error = error {
                print("DEBUG: failed to fetch coin doc with error \(error.localizedDescription)")
            } else {
                // Check if the document exists
                if let document = document, document.exists {
                    // Document exists -> update coins field (and view)
                    if let totalCoins = document.get("total_coins") {
                        self.coins = totalCoins as! Int
                    }
                } else {
                    // Document does not exist -> add new document
                    collection.document(self.uid).setData([
                        "total_coins": 0,
                    ]) { error in
                        if let error = error {
                            print("DEBUG: Error adding coin document: \(error)")
                        }
                    }
                }
            }
        }
    }
}
