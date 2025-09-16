//
//  WaspitoPlusApp.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/16/25.
//

import SwiftUI

@main
struct WaspitoPlusApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
