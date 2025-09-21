//
//  LoginView.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri on 9/16/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var vm = AuthViewModel()
    
    @StateObject private var localizationManager = LocalizationManager.shared
    
    @State private var isSecure: Bool = true
    
    var body: some View {
        VStack(spacing: 20) {
            
             HStack {
                Spacer()
                Button(action: {
                    localizationManager.toggleLanguage()
                }) {
                    Text(localizationManager.currentLanguage == "en" ? "Français" : "English")
                        .font(.caption)
                        .padding(8)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
             Text(localizationManager.localizedString(for: "Register/Login"))
                .font(.largeTitle)
                .bold()
            
             VStack(alignment: .leading, spacing: 15) {
                Text(localizationManager.localizedString(for: "email"))
                    .font(.headline)
                TextField(localizationManager.localizedString(for: "email"), text: $vm.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                Text(localizationManager.localizedString(for: "password"))
                    .font(.headline)
                if isSecure {
                    SecureField(localizationManager.localizedString(for: "password"), text: $vm.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    TextField(localizationManager.localizedString(for: "password"), text: $vm.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                 		
                Button(action: {
                    isSecure.toggle()
                }) {
                    Text(isSecure ? "Show" : "Hide")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
             if !vm.errorMessage.isEmpty {
                Text(vm.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
             Button(action: {
                vm.login()
            }) {
                Text(localizationManager.localizedString(for: "login"))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
             Button(action: {
                vm.register()
            }) {
                Text(localizationManager.localizedString(for: "register"))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .fullScreenCover(isPresented: $vm.isAuthenticated) {
            HomeView()
        }
    }
}

#Preview {
    LoginView()
}

