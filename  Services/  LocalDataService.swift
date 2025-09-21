 
final class LocalDataService {
    static let shared = LocalDataService()
    private init() {}

     private var symptomEntriesStorage: [SymptomEntry] = []

     func saveEntry(_ entry: SymptomEntry) {
        symptomEntriesStorage.append(entry)
    }

     func addEntry(_ entry: SymptomEntry) {
        symptomEntriesStorage.append(entry)
    }

     func getAllEntries() -> [SymptomEntry] {
        return symptomEntriesStorage
    }

     func deleteEntry(_ entry: SymptomEntry) {
        symptomEntriesStorage.removeAll { $0.id == entry.id }
    }

     func updateEntry(_ entry: SymptomEntry) {
        if let index = symptomEntriesStorage.firstIndex(where: { $0.id == entry.id }) {
            symptomEntriesStorage[index] = entry
        }
    }

     func hasPendingEntries() -> Bool {
        return symptomEntriesStorage.contains { !$0.isSynced }
    }

     func syncPendingEntries() {
        for index in 0..<symptomEntriesStorage.count {
            if !symptomEntriesStorage[index].isSynced {
                symptomEntriesStorage[index].isSynced = true
            }
        }
    }

     func markDoctorNotified(for entry: SymptomEntry) {
        if let index = symptomEntriesStorage.firstIndex(where: { $0.id == entry.id }) {
            symptomEntriesStorage[index].doctorNotified = true
        }
    }
}
