//
//  LoginView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/3/23.
//

import SwiftUI
import AuthenticationServices
                                               // converts ui kit view to swift ui
struct LoginView: View {
    
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme
    
    var bannerImageHeight: CGFloat {
        return horizontalSizeClass == .regular ? 270 : 120
    }
    
    var inputFieldsPadding: CGFloat {
        return horizontalSizeClass == .regular ? 50 : 12
    }
    
    var signInWithAppleStyle: ASAuthorizationAppleIDButton.Style {
        return (colorScheme == .dark) ? .white : .black
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // icon
                Image("banner")
                    .resizable()
                    .scaledToFill()
                    .frame(height: bannerImageHeight)
                    .padding(.bottom, 70)
                
                // input fields
                VStack(spacing: 24) {
                    InputView(
                        text: $email,
                        title: "Email Address",
                        placeholder: "john@example․com")
                        .autocapitalization(.none)
                    InputView(
                        text: $password,
                        title: "Password",
                        placeholder: "Enter your password",
                        isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top, inputFieldsPadding)
                
                // sign in with email
                Button {
                    Task {
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                    
                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .cornerRadius(10)
                .padding(.top)
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                
                // sign in with apple
                SignInWithAppleButton { (request) in
                    viewModel.nonce = randomNonceString()
                    request.requestedScopes = [.email]
                    request.nonce = sha256(viewModel.nonce)
                } onCompletion: { (result) in
                    switch result {
                    case .success(let user):
                        // do login with firebase
                        print("success")
                        guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                            print("DEBUG: error with firebase")
                            return
                        }
                        Task {
                            try await viewModel.authenticate(credential: credential)
                        }
                    case .failure(let error):
                        print("sign in with apple error: \(error.localizedDescription)")
                    }
                }
                .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                .cornerRadius(10)
                .padding(.top, 5)
                
                
                Spacer()
                
                // sign up
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                    .padding(.bottom)
                }
                .alert(isPresented: $viewModel.signInAlert) {
                    return viewModel.constructSignInAlert()
                }
            }
            
        }
    }
}

// MARK: - AuthenticationFormProtocol

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
