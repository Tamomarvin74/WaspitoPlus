//
//  LocalizationManager.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri on 9/16/25.
//

import Foundation
import Combine

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String
    
    private init() {
         if let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage") {
            currentLanguage = savedLanguage
        } else {
            currentLanguage = "en"
        }
    }
    
    func toggleLanguage() {
        currentLanguage = (currentLanguage == "en") ? "fr" : "en"
        UserDefaults.standard.set(currentLanguage, forKey: "appLanguage")
        objectWillChange.send()
    }
    
    func localizedString(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return key
        }
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: key, comment: "")
    }
}

