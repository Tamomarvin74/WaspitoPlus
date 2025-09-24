//
//  AuthViewModel.swift
//  WaspitoPlus
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var userName: String = ""
    @Published var errorMessage: String = ""
    
    func register() {
        AuthService.shared.register(email: email, password: password) { [weak self] result in
            switch result {
            case .success(let user):
                self?.userName = user.displayName ?? ""
                self?.isAuthenticated = true
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    func login() {
        AuthService.shared.login(email: email, password: password) { [weak self] result in
            switch result {
            case .success(let user):
                self?.userName = user.displayName ?? "" 
                self?.isAuthenticated = true
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    func signOut() {
        do {
            try AuthService.shared.signOut()  
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
        
        self.isAuthenticated = false
        self.email = ""
        self.password = ""
        self.userName = ""
        self.errorMessage = ""
    }
}

