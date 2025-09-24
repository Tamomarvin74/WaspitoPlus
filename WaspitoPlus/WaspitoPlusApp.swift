//
//  WaspitoPlusApp.swift
//  WaspitoPlus
//  Created by Tamo Marvin Achiri on 9/16/25.
//

 

import SwiftUI
import FirebaseCore
import UIKit

@main
struct WaspitoPlusApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(authVM)  
                .onAppear {
                    NotificationManager.shared.configure()
                    NotificationManager.shared.requestAuthorization { granted in
                        print("Notifications authorized: \(granted)")
                    }

                    LocalDataService.shared.syncPendingEntries()
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

