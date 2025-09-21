import Foundation

final class DoctorNotificationManager {
    static let shared = DoctorNotificationManager()
    private init() {}

     func notifyDoctor(for entry: SymptomEntry) {
 
         print("Doctor notified about patient: \(entry.name), phone: \(entry.phone)")
    }
}

