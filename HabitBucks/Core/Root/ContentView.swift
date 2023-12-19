//
//  ContentView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/3/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var coinManager: CoinManager
    @EnvironmentObject var shopViewModel: ShopViewModel
    @EnvironmentObject var taskViewModel: TaskViewModel
    @State private var selectedTab = 1 // set default to task list
    // TODO: if i set this to profile what will happen?? breaks still...
    private var contentViewLoading = true

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else {
                if viewModel.userSession != nil && viewModel.currentUser != nil {
                    TabView(selection: $selectedTab) {
                        
                        ShopView()
                            .tabItem {
                                Image(systemName: "cart")
                                Text("Shop")
                            }
                            .tag(0)
                        TaskView()
                            .tabItem {
                                Image(systemName: "list.clipboard")
                                Text("Tasks")
                            }
                            .tag(1)
                        ProfileView()
                            .tabItem {
                                Image(systemName: "person.crop.circle.fill")
                                Text("Profile")
                            }
                            .tag(2)

                        // Add more tabs as needed
                    }
                    .edgesIgnoringSafeArea(.top)
                    .task {
                        await CoinManager.shared.setupSubscription()
                        await ShopViewModel.shared.asyncSetup()
                        await TaskViewModel.shared.asyncSetup()
                        // TODO: add more fetch stuff here!?
                    }
                } else {
                    LoginView()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ContentView()
                .environmentObject(AuthViewModel())
                .environmentObject(CoinManager())
                .environmentObject(ShopViewModel())
                .environmentObject(TaskViewModel())
        }
    }
}
