import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var symptomEntries: [SymptomEntry] = []

    private let localDataService = LocalDataService.shared

    init() {
        fetchEntries()
    }

    func fetchEntries() {
        symptomEntries = localDataService.getAllEntries()
    }

    func deleteEntry(at offsets: IndexSet) {
        offsets.forEach { index in
            let entry = symptomEntries[index]
            localDataService.deleteEntry(entry)
        }
        fetchEntries()
    }

    func syncEntriesIfPending() {
 
        if localDataService.hasPendingEntries() {
            localDataService.syncPendingEntries()
            fetchEntries()
        }
    }
}

