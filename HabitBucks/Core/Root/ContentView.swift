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
    @State private var selectedTab = 2 // set default to task list
    // TODO: if i set this to profile what will happen?? breaks still...
    private var contentViewLoading = true

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else {
                if viewModel.userSession != nil && viewModel.currentUser != nil {
                    TabView(selection: $selectedTab) {
                        AnalysisView()
                            .tabItem {
                                Image(systemName: "chart.pie.fill")
                                Text("Analysis")
                            }
                            .tag(0)
                        
                        PomodoroView()
                            .tabItem {
                                Image(systemName: "timer")
                                Text("Pomodoro")
                            }
                            .tag(1)
                        
                        TaskView()
                            .tabItem {
                                Image(systemName: "list.clipboard")
                                Text("Tasks")
                            }
                            .tag(2)
                        
                        ShopView()
                            .tabItem {
                                Image(systemName: "cart")
                                Text("Shop")
                            }
                            .tag(3)
                        
                        ProfileView()
                            .tabItem {
                                Image(systemName: "person.crop.circle.fill")
                                Text("Profile")
                            }
                            .tag(4)

                        // Add more tabs as needed
                    }
                    .edgesIgnoringSafeArea(.top)
                    .task {
                        await CoinManager.shared.setupSubscription()
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
        }
    }
}
