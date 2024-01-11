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
            NavigationView {
                List {
                    Section {
                        HStack {
                            Image("icon")
                                .resizable()
                                .frame(width: 65, height: 65)
                            Text(user.email)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Section("General") {
                        HStack {
                            SettingsRowView(imageName: "gear",
                                            title: "Version",
                                            tintColor: Color(.systemGray))
                            Spacer()
                            Text("1.0")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        NavigationLink {
                            HowToUseView()
                        } label: {
                            SettingsRowView(imageName: "questionmark.circle.fill",
                                            title: "How to use",
                                            tintColor: Color(.systemGray))
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
                            viewModel.deleteAccountClicked()
                        } label: {
                            SettingsRowView(imageName: "xmark.circle.fill",
                                            title: "Delete Account",
                                            tintColor: Color(.red))
                        }
                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                return viewModel.constructDeleteAccountAlert()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(CoinManager())
            .environmentObject(AuthViewModel())
    }
}
