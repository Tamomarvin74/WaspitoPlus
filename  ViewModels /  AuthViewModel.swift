//
//    AuthViewModel.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/16/25.
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String = ""
    
     func register() {
        AuthService.shared.register(email: email, password: password) { [weak self] result in
            switch result {
            case .success(_):
                self?.isAuthenticated = true   
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
     func login() {
        AuthService.shared.login(email: email, password: password) { [weak self] result in
            switch result {
            case .success(_):
                self?.isAuthenticated = true
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
}

