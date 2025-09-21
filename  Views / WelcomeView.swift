//
//  WelcomeView.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri on 9/17/25.
//

import SwiftUI

struct WelcomeView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var currentPage = 0
    @State private var showLogin = false
    
    var body: some View {
        VStack {
            
             HStack {
                Spacer()
                Toggle(isOn: Binding(
                    get: { localizationManager.currentLanguage == "fr" },
                    set: { localizationManager.currentLanguage = $0 ? "fr" : "en" }
                )) {
                    Text(localizationManager.currentLanguage.uppercased())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .padding()
            }
            
            Spacer()
            
             VStack(spacing: 20) {
                 Image("WaspitoLogo")
                 
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                 Text("Waspito")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                 Text(localizationManager.localizedString(for: "welcome"))
                    .font(.title3)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
             HStack(spacing: 8) {
                Circle()
                    .fill(currentPage == 0 ? Color.green : Color.gray.opacity(0.4))
                    .frame(width: 8, height: 8)
                Circle()
                    .fill(currentPage == 1 ? Color.green : Color.gray.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
            .padding(.bottom, 30)
            
             Button(action: {
                showLogin = true
            }) {
                Text(localizationManager.localizedString(for: "signIn"))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(25)
                    .padding(.horizontal, 40)
            }
            .fullScreenCover(isPresented: $showLogin) {
                LoginView()
            }
            
            Spacer(minLength: 40)
        }
    }
}

#Preview {
    WelcomeView()
}

