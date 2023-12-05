//
//  HabitBucksApp.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/3/23.
//

import SwiftUI
import Firebase

@main
struct HabitBucksApp: App {
    @StateObject var authViewModel = AuthViewModel.shared
    @StateObject var coinManager = CoinManager.shared
    @StateObject var shopViewModel = ShopViewModel.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(coinManager)
                .environmentObject(shopViewModel)
        }
    }
}
