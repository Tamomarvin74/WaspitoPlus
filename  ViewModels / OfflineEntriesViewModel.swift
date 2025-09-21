import Foundation
import SwiftUI
import Combine

@MainActor
final class OfflineEntriesViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var phone: String = ""
    @Published var age: String = ""
    @Published var gender: String = "Male"
    @Published var symptoms: String = ""
    @Published var details: String = ""
    @Published var isHealthy: Bool = false
    @Published var diagnosisMessage: String = ""
    @Published var entries: [SymptomEntry] = []

    private let localDataService = LocalDataService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadEntries()
        observeNetworkChanges()
    }

     func loadEntries() {
        entries = localDataService.getAllEntries()
    }

    func submitEntry() {
        let newEntry = SymptomEntry(
            id: UUID(),
            name: name,
            phone: phone,
            title: "Symptom Entry - \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))",
            age: age,
            gender: gender,
            symptoms: symptoms,
            result: diagnosisMessage,
            details: details,
            date: Date(),
            isSynced: false,
            isHealthy: isHealthy
        )
        localDataService.addEntry(newEntry)
        DoctorNotificationManager.shared.notifyDoctor(for: newEntry)
        loadEntries()
        clearForm()
    }


    func deleteEntry(at offsets: IndexSet) {
        offsets.forEach { index in
            let entry = entries[index]
            localDataService.deleteEntry(entry)
        }
        loadEntries()
    }

    private func clearForm() {
        name = ""
        phone = ""
        age = ""
        gender = "Male"
        symptoms = ""
        details = ""
        isHealthy = false
        diagnosisMessage = ""
    }

     var hasPendingEntries: Bool {
        localDataService.getAllEntries().contains { !$0.isSynced }
    }

    func syncEntries() {
        localDataService.getAllEntries()
            .filter { !$0.isSynced }
            .forEach { entry in
                var syncedEntry = entry
                syncedEntry.isSynced = true
                localDataService.updateEntry(syncedEntry)
            }
        loadEntries()
    }

    func startAutoSync() {
        NetworkMonitor.shared.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self = self else { return }
                if isConnected {
                    self.syncEntries()
                }
            }
            .store(in: &cancellables)
    }

     private func observeNetworkChanges() {
        NetworkMonitor.shared.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self = self else { return }
                if isConnected, self.hasPendingEntries {
                    self.syncEntries()
                }
            }
            .store(in: &cancellables)
    }
}

