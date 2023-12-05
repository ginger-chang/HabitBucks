//
//  ProfileView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/3/23.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var coinManager: CoinManager
    
    var body: some View {
        if let user = viewModel.currentUser {
            List {
                Section {
                    HStack {
                        Text(user.initials)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .font(.title)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.username)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            Text(user.email)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    
                }
                
                Section("General") {
                    HStack {
                        SettingsRowView(imageName: "gear",
                                        title: "Version",
                                        tintColor: Color(.systemGray))
                        Spacer()
                        Text("1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Section("Account") {
                    Button {
                        viewModel.signOut()
                    } label: {
                        SettingsRowView(imageName: "arrow.left.circle.fill",
                                        title: "Sign Out",
                                        tintColor: Color(.red))
                    }

                    Button {
                        print("delete account..")
                    } label: {
                        SettingsRowView(imageName: "xmark.circle.fill",
                                        title: "Delete Account",
                                        tintColor: Color(.red))
                    }
                }
                // MARK: this is just a quick preview/test
                Section("Coins") {
                    Button {
                        coinManager.addCoins(n: 5)
                    } label: {
                        Text("add 5")
                    }
                    Button {
                        coinManager.minusCoins(n: 3)
                    } label: {
                        Text("minus 3")
                    }
                    Text("\(coinManager.coins)")
                }
            }
            .task {
                await coinManager.setupSubscription()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
